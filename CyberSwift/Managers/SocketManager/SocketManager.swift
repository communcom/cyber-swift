//
//  SocketManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream
import Reachability

public class SocketManager {
    // MARK: - Nested type
    public enum Event: Equatable {
        case connecting
        case connected
        case signed
        case disconnected(ErrorAPI?)
    }
    
    // MARK: - Properties
    var socket = WebSocket(url: URL(string: Config.gate_API_URL + "connect?platform=ios&deviceType=phone&clientType=app&version=\(UIApplication.appVersion)\((KeychainManager.currentDeviceId != nil) ? "&deviceId=\(KeychainManager.currentDeviceId!)" : "")")!)
    
    public let state = BehaviorRelay<Event>(value: .connecting)
    public let textSubject = PublishSubject<String>()
    
    let bag = DisposeBag()
    var reachability: Reachability!
    
    public let unseenNotificationsRelay = BehaviorRelay<UInt64>(value: 0)
    public let newNotificationsRelay = BehaviorRelay<[ResponseAPIGetNotificationItem]>(value: [])
    
    // MARK: - Singleton
    public static let shared = SocketManager()
    private init() {
        socket.delegate = self
        
        // sign when socket is connected
        observeConnection()
        
        // network monitoring
        monitorNetwork()
    }
    
    // MARK: - Methods
    public func connect() {
        state.accept(.connecting)
        socket.connect()
    }
    
    public func disconnect() {
        socket.disconnect()
    }
    
    public func deviceIdDidSet() {
        guard let id = KeychainManager.currentDeviceId else {return}
        socket.disconnect()
        let urlString = Config.gate_API_URL + "connect?platform=ios&deviceType=phone&clientType=app&version=\(UIApplication.appVersion)&deviceId=\(id)"
        socket = WebSocket(url: URL(string: urlString)!)
        socket.connect()
    }
    
    func sendRequest<T: Decodable>(methodAPIType: RequestMethodAPIType, timeout: RxSwift.RxTimeInterval) -> Single<T> {
        sendMessage(methodAPIType.requestMessage!)
        
        return textSubject
            .filter {self.compareMessageFromResponseText($0, to: methodAPIType.id)}
            .timeout(timeout, scheduler: MainScheduler.instance)
            .take(1)
            .asSingle()
            .map {try self.transformMessage($0)}
    }
    
    func sendMessage(_ message: String) {
        if !socket.isConnected {
            state.accept(.connecting)
            state.filter {$0 == .signed}
                .take(1)
                .asSingle()
                .subscribe(onSuccess: {[weak self] _ in
                    self?.socket.write(string: message)
                })
                .disposed(by: bag)
            connect()
        } else {
            socket.write(string: message)
        }
    }
    
    func observeConnection() {
        catchEvent("notifications.statusUpdated", objectType: ResponseAPINotificationsStatusUpdated.self)
            .subscribe(onNext: { (status) in
                self.unseenNotificationsRelay.accept(status.unseenCount)
            })
            .disposed(by: bag)
        
        catchEvent("notifications.newNotification", objectType: ResponseAPIGetNotificationItem.self)
            .subscribe(onNext: { (item) in
                var newNotifications = self.newNotificationsRelay.value
                newNotifications.joinUnique([item])
                self.newNotificationsRelay.accept(newNotifications.sortedByTimestamp)
            })
            .disposed(by: bag)
    }
    
    func monitorNetwork() {
        reachability = Reachability()
        reachability.whenReachable = { _ in
            self.connect()
        }
        try? reachability.startNotifier()
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    public func catchEvent<T: Decodable>(_ method: String, objectType: T.Type) -> Observable<T> {
        textSubject
            .filter { string in
                guard let jsonData = string.data(using: .utf8),
                    let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any]
                    else {
                        return false
                }
                return (json["method"] as? String) == method
            }
            .map { string -> SocketResponse<T> in
                Logger.log(message: "\(method): \(string)", event: .event)
                guard let data = string.data(using: .utf8) else {throw ErrorAPI.responseUnsuccessful(message: string)}
                return try JSONDecoder().decode(SocketResponse<T>.self, from: data)
            }
            .map {$0.params}
    }
}

extension SocketManager {
    // MARK: - Helpers
    /// Filter message
    fileprivate func compareMessageFromResponseText(_ text: String, to requestId: Int) -> Bool {
        guard let jsonData = text.data(using: .utf8),
            let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any],
            let id = json["id"] as? Int
            else {
                return false
        }
        
        return requestId == id
    }
    
    /// validate message
    fileprivate func validate(jsonData: Data) throws {
        guard let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any] else {
            throw ErrorAPI.invalidData(message: "Response Unsuccessful")
        }
        
        guard (json["id"] as? Int) != nil else {
            // Get error
            let jsonDecoder = JSONDecoder()
            
            // Catch error
            if let responseAPIResultError = try? jsonDecoder.decode(ResponseAPIErrorResult.self, from: jsonData) {
                throw ErrorAPI.requestFailed(message: responseAPIResultError.error.message.components(separatedBy: "second.end(): ").last!)
            }
            
            // If no error matching
            throw ErrorAPI.invalidData(message: "Message Id not found")
        }
        
        return
    }
    
    /// Transform text message to object
    func transformMessage<T: Decodable>(_ text: String) throws -> T {
        Logger.log(message: "websocketDidReceiveMessage: \n\t\(text)", event: .response)
        
        guard let jsonData = text.data(using: .utf8) else {
            throw ErrorAPI.invalidData(message: "Response Unsuccessful")
        }
        
        // Get messageId
        try validate(jsonData: jsonData)
        
        // Decode json
        let response = try JSONDecoder().decode(ResponseAPIResult<T>.self, from: jsonData)
        
        if let result = response.result {
            return result
        } else if let error = response.error {
            let message = error.data?.error?.details?.first?.message.replacingOccurrences(of: "assertion failure with message: ", with: "") ?? error.data?.message ?? error.message

            if message == "balance does not exist" {
                throw ErrorAPI.balanceNotExist(message: message)
            }

            if message == "Invalid step taken", let currentState = error.currentState {
                throw ErrorAPI.registrationRequestFailed(message: message, currentStep: currentState)
            }
            
            throw ErrorAPI.requestFailed(message: message)
        } else {
            throw ErrorAPI.unknown
        }
    }
}

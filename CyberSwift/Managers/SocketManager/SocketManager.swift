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
import SwiftyJSON
import Reachability

public enum WebSocketEvent {
    case connected
    case disconnected(Error?)
    case message(String)
    case data(Data)
    case pong
}

public class SocketManager {
    // MARK: - Properties
    var socket = WebSocket(url: URL(string: Config.gate_API_URL + "connect?platform=ios&deviceType=phone&clientType=app&version=\(UIApplication.appVersion)\((KeychainManager.currentDeviceId != nil) ? "&deviceId=\(KeychainManager.currentDeviceId!)" : "")")!)
    
    let subject = PublishSubject<WebSocketEvent>()
    public let connected = BehaviorRelay<Bool>(value: false)
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
    
    func sendRequest<T: Decodable>(methodAPIType: RequestMethodAPIType) -> Single<T> {
        sendMessage(methodAPIType.requestMessage!)
        
        return text
            .filter {self.compareMessageFromResponseText($0, to: methodAPIType.id)}
            .timeout(10, scheduler: MainScheduler.instance)
            .take(1)
            .asSingle()
            .map {try self.transformMessage($0)}
    }
    
    func sendMessage(_ message: String) {
        if !socket.isConnected {
            connect()
            connected
                .filter {$0}
                .take(1)
                .asSingle()
                .subscribe(onSuccess: {[weak self] _ in
                    self?.socket.write(string: message)
                })
                .disposed(by: bag)
        } else {
            socket.write(string: message)
        }
    }
    
    func observeConnection() {
        text
            .subscribe(onNext: { (text) in
                if let data = text.data(using: .utf8),
                    let json = try? JSON(data: data) {
                    
                    // Retrieve secret
                    if let secret = json["params"]["secret"].string {
                        Config.webSocketSecretKey = secret
                        self.connected.accept(true)
                    }
                }
            })
            .disposed(by: bag)
        
        subject
            .subscribe(onNext: { (event) in
                switch event {
                case .disconnected:
                    self.connected.accept(false)
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        catchMethod("notifications.statusUpdated", objectType: SocketResponseNotificationsStatusUpdated.self)
            .subscribe(onNext: { (status) in
                self.unseenNotificationsRelay.accept(status.unseenCount)
            })
            .disposed(by: bag)
        
        catchMethod("notifications.newNotification", objectType: ResponseAPIGetNotificationItem.self)
            .subscribe(onNext: { (item) in
                let newNotifications = ResponseAPIGetNotificationItem.join(array1: self.newNotificationsRelay.value, array2: [item])
                self.newNotificationsRelay.accept(newNotifications)
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
        subject.onCompleted()
        reachability.stopNotifier()
    }
    
    public func catchMethod<T: Decodable>(_ method: String, objectType: T.Type) -> Observable<T> {
        text
            .filter { string in
                guard let jsonData = string.data(using: .utf8),
                    let json = (try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)) as? [String: Any]
                    else {
                        return false
                }
                return (json["method"] as? String) == method
            }
            .map { string -> SocketResponse<T> in
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
        
        guard ((json["id"] as? Int) != nil) else {
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

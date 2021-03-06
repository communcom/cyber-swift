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

class SocketManager {
    // MARK: - Nested type
    enum Event: Equatable {
        case connecting
        case connected
        case signed
        case disconnected(CMError?)
    }
    
    // MARK: - Properties
    var socket: WebSocket
    
    let state = BehaviorRelay<Event>(value: .connecting)
    let textSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    var reachability: Reachability!
    
    // MARK: - Singleton
    static let shared = SocketManager()
    private init() {
        // Create device id
        KeychainManager.createDeviceId()
        
        // init socket
        socket = WebSocket(url: URL(string: Config.gate_API_URL + "connect?platform=ios&deviceType=phone&clientType=app&version=\(UIApplication.appVersion)\((KeychainManager.currentDeviceId != nil) ? "&deviceId=\(KeychainManager.currentDeviceId!)" : "")")!)
        
        socket.delegate = self
        
        // network monitoring
        monitorNetwork()
    }
    
    // MARK: - Methods
    func connect() {
        state.accept(.connecting)
        socket.connect()
    }
    
    func disconnect() {
        state.accept(.disconnected(nil))
        socket.disconnect()
    }
    
    func reset() {
        if KeychainManager.currentDeviceId == nil
        {
            KeychainManager.createDeviceId()
        }
        disconnect()
        let urlString = Config.gate_API_URL + "connect?platform=ios&deviceType=phone&clientType=app&version=\(UIApplication.appVersion)\((KeychainManager.currentDeviceId != nil) ? "&deviceId=\(KeychainManager.currentDeviceId!)" : "")"
        socket = WebSocket(url: URL(string: urlString)!)
        connect()
        socket.delegate = self
    }
    
    func sendRequest<T: Decodable>(id: Int, methodGroup: MethodAPIGroup, methodName: String, params: [String: Encodable], timeout: RxSwift.RxTimeInterval, authorizationRequired: Bool) -> Single<T> {
        let requestAPI = RequestAPI(
            id: id,
            method: methodGroup.rawValue + "." + methodName,
            jsonrpc: "2.0",
            params: params
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestAPI)
            guard let message = String(data: jsonData, encoding: .utf8) else {
                throw CMError.invalidRequest(message: "could not encode request")
            }
            sendMessage(methodGroup: methodGroup, methodName: methodName, message: message, authorizationRequired: authorizationRequired)
            
            return textSubject
                .filter {self.compareMessageFromResponseText($0, to: id)}
                .timeout(timeout, scheduler: MainScheduler.instance)
                .take(1)
                .asSingle()
                .do(onSuccess: { (text) in
                    Logger.log(message: "websocketDidReceiveMessage: \n\t\(text)", event: .response, apiMethod: "\(methodGroup).\(methodName)")
                })
                .map {try self.transformMessage($0)}
            
        } catch {
            return .error(error.cmError)
        }
    }
    
    func sendMessage(methodGroup: MethodAPIGroup, methodName: String, message: String, authorizationRequired: Bool) {
        // check connection and send
        if !socket.isConnected {
            connect()
            if authorizationRequired {
                AuthManager.shared.status.filter {$0 == .authorized}
                    .take(1)
                    .asSingle()
                    .subscribe(onSuccess: { (_) in
                        self.writeAndLog(message: message, methodGroup: methodGroup.rawValue, methodName: methodName)
                    })
                    .disposed(by: disposeBag)
            } else {
                state.filter {$0 == .signed}
                    .take(1)
                    .asSingle()
                    .subscribe(onSuccess: {[weak self] _ in
                        self?.writeAndLog(message: message, methodGroup: methodGroup.rawValue, methodName: methodName)
                    })
                    .disposed(by: disposeBag)
            }
        } else {
            if authorizationRequired {
                AuthManager.shared.status.filter {$0 == .authorized}
                    .take(1)
                    .asSingle()
                    .subscribe(onSuccess: { (_) in
                        self.writeAndLog(message: message, methodGroup: methodGroup.rawValue, methodName: methodName)
                    })
                    .disposed(by: disposeBag)
            } else {
                writeAndLog(message: message, methodGroup: methodGroup.rawValue, methodName: methodName)
            }
        }
    }
    
    private func writeAndLog(message: String, methodGroup: String, methodName: String) {
        Logger.log(message: "\nrequestMethodAPIType:\n\t\(message)\n", event: .request, apiMethod: "\(methodGroup).\(methodName)")
        socket.write(string: message)
    }
    
    func monitorNetwork() {
        reachability = Reachability()
        reachability.whenReachable = { _ in
            self.connect()
        }
        reachability.whenUnreachable = { _ in
            self.state.accept(.disconnected(.noConnection))
        }
        try? reachability.startNotifier()
    }
    
    deinit {
        reachability.stopNotifier()
    }
    
    func catchEvent<T: Decodable>(_ method: String, objectType: T.Type) -> Observable<T> {
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
                guard let data = string.data(using: .utf8) else {
                    throw CMError.invalidResponse(responseString: string)
                }
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
            throw CMError.invalidResponse(message: ErrorMessage.jsonParsingFailed.rawValue)
        }
        
        guard (json["id"] as? Int) != nil else {
            // Get error
            let jsonDecoder = JSONDecoder()
            
            // Catch error
            if let responseAPIResultError = try? jsonDecoder.decode(ResponseAPIErrorResult.self, from: jsonData) {
                throw CMError.requestFailed(message: responseAPIResultError.error.message.components(separatedBy: "second.end(): ").last!, code: responseAPIResultError.error.code)
            }
            
            // If no error matching
            throw CMError.invalidResponse(message: ErrorMessage.messageIdNotFound.rawValue)
        }
        
        return
    }
    
    /// Transform text message to object
    func transformMessage<T: Decodable>(_ text: String) throws -> T {
        
        guard let jsonData = text.data(using: .utf8) else {
            throw CMError.invalidResponse(message: ErrorMessage.jsonParsingFailed.rawValue, responseString: text)
        }
        
        // Get messageId
        try validate(jsonData: jsonData)
        
        // Decode json
        let response = try JSONDecoder().decode(ResponseAPIResult<T>.self, from: jsonData)
        
        if let result = response.result {
            return result
        } else if let error = response.error {
            let message = error.data?.error?.details?.first?.message.replacingOccurrences(of: "assertion failure with message: ", with: "") ?? error.data?.message ?? error.message
            
            if message == "Unauthorized request: access denied" {
                throw CMError.unauthorized()
            }
            
            if message == "There is no secret stored for this channelId. Probably, client's already authorized" ||
                message == "Secret verification failed - access denied"
            {
                throw CMError.secretVerificationFailed
            }

            if message == "balance does not exist" {
                throw CMError.blockchainError(message: ErrorMessage.balanceNotExist.rawValue, code: error.code)
            }

            if message == ErrorMessage.invalidStepTaken.rawValue, let currentState = error.currentState {
                throw CMError.registration(message: ErrorMessage.invalidStepTaken.rawValue, currentState: currentState)
            }
            
            if message == "Cannot get such account from BC" || message.hasPrefix("Can't resolve name")
            {
                throw CMError.userNotFound
            }
            
            if message == "Account already registered" {
                throw CMError.registration(message: ErrorMessage.accountHasBeenRegistered.rawValue)
            }
            
            throw CMError.requestFailed(message: message, code: error.code)
        } else {
            throw CMError.invalidResponse(responseString: text)
        }
    }
}

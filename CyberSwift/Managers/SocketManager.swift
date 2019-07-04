//
//  SocketManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Starscream
import RxStarscream

public class SocketManager {
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Singleton
    public static let shared = SocketManager()
    let bag = DisposeBag()
    
    // MARK: - Properties
    public let socket = WebSocket(url: URL(string: Config.gate_API_URL)!)
    public let authorized = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Methods
    func connect() {
        socket.connect()
        socket.rx.connected
            .filter {$0}
            .take(1)
            .subscribe(onNext: {_ in self.socketConnectedHandler()})
            .dispose()
    }
    
    func disconnect() {
        guard socket.isConnected else {return}
        socket.disconnect()
    }
    
    func sendRequest(methodAPIType: RequestMethodAPIType) -> Single<Decodable> {
        if !socket.isConnected {
            // Reconnect
            socket.connect()
            
            // Rewrite message after connecting
            socket.rx.connected
                .filter {$0}
                .take(1)
                .subscribe(onNext: {_ in
                    self.socket.write(string: methodAPIType.requestMessage!)
                })
                .disposed(by: bag)
            
        } else {
            // Send message
            socket.write(string: methodAPIType.requestMessage!)
        }
        
        // Wait for correct message
        return .create {single in
            self.socket.rx.text
                .filter {self.compareMessageFromResponseText($0, to: methodAPIType.id)}
                .take(1)
                .map {try self.transformMessage($0, to: methodAPIType.methodAPIType)}
                .subscribe(onNext: { (result) in
                    single(.success(result))
                }, onError: { (error) in
                    single(.error(error))
                })
                .disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    // MARK: - Handlers
    func socketConnectedHandler() {
        if !CurrentUser.loggedIn {
            authorized.accept(false)
            return
        }
        
        // Authorize
        RestAPIManager.instance.rx.authorize()
            .subscribe(onSuccess: { (_) in
                self.authorized.accept(true)
            }) { (error) in
                self.authorized.accept(false)
            }
            .disposed(by: bag)
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
        
        guard let _ = json["id"] as? Int else {
            if let params = json["params"] as? Dictionary<String, String>, let paramsSecret = params["secret"] {
                Config.webSocketSecretKey = paramsSecret
            }
            
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
    func transformMessage(_ text: String, to type: MethodAPIType) throws -> Decodable {
        Logger.log(message: "websocketDidReceiveMessage: \n\t\(text)", event: .severe)
        
        guard let jsonData = text.data(using: .utf8) else {
            throw ErrorAPI.invalidData(message: "Response Unsuccessful")
        }
        
        // Get messageId
        try validate(jsonData: jsonData)
        
        // Decode json
        let response = try type.decode(from: jsonData)
        
        // get result
        guard let result = response.responseAPI else {
            if let error = response.errorAPI {
                throw error
            }
            throw ErrorAPI.unknown
        }
        
        return result
    }
}

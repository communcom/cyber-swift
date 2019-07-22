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
    // MARK: - Singleton
    private init() {}
    public static let shared = SocketManager()
    
    // MARK: - Properties
    public let socket = WebSocket(url: URL(string: Config.gate_API_URL)!)
    
    // MARK: - Methods
    public func connect() {
        socket.connect()
    }
    
    public func disconnect() {
        guard socket.isConnected else {return}
        socket.disconnect()
    }
    
    func sendRequest(methodAPIType: RequestMethodAPIType) -> Single<ResponseAPIType> {
        return self.socket.rx.text
            .filter {self.compareMessageFromResponseText($0, to: methodAPIType.id)}
            .asSingle()
            .map {try self.transformMessage($0, to: methodAPIType.methodAPIType)}
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
    func transformMessage(_ text: String, to type: MethodAPIType) throws -> ResponseAPIType {
        Logger.log(message: "websocketDidReceiveMessage: \n\t\(text)", event: .severe)
        
        guard let jsonData = text.data(using: .utf8) else {
            throw ErrorAPI.invalidData(message: "Response Unsuccessful")
        }
        
        // Get messageId
        try validate(jsonData: jsonData)
        
        // Decode json
        let response = try type.decode(from: jsonData)
        
        return response
    }
}


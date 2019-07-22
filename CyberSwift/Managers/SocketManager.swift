//
//  SocketManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import SwiftSocket
import RxSwift

public class SocketManager {
    // MARK: - Singleton
    private init() {}
    public static var shared = SocketManager()
    
    // MARK: - Properties
    private let client = TCPClient(address: Config.gate_API_IP_Address, port: Config.gate_API_IP_Port)
    
    // MARK: - Methods
    public func connect() -> Completable {
        switch client.connect(timeout: 10) {
        case .success:
            // Sign
            return .empty()
        case .failure(let error):
            return .error(error)
        }
    }
    
    public func disconnect() {
        client.close()
    }
    
    public func sendRequest(methodAPIType: RequestMethodAPIType) -> Single<ResponseAPIType> {
        let message = methodAPIType.requestMessage!
        Logger.log(message: "\nrequestMessage = \n\t\(message)", event: .info)
        
        switch client.send(string: message) {
        case .success:
            guard let data = client.read(1024*10) else {return .error(ErrorAPI.responseUnsuccessful(message: "Can not retrieve data"))}
            if let response = String(bytes: data, encoding: .utf8) {
                return Single<String>.just(response)
                    .map {_ in try self.transformMessage(response, to: methodAPIType.methodAPIType)}
            } else {
                return .error(ErrorAPI.responseUnsuccessful(message: "Can not transform response to string"))
            }
        case .failure(let error):
            return .error(error)
        }
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

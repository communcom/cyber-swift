//
//  WebsocketManager.swift
//  CyberSwift
//
//  Created by Grigory on 15/02/2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation
import Starscream

var webSocket = WebSocket(url: URL(string: "ws://116.203.98.241:8080")!)

public class WebSocketManager {
    // MARK: - Properties
    public static let instance = WebSocketManager()
    
    private var errorAPI: ErrorAPI?
    
    private var requestMethodsAPIStore = [Int: RequestMethodAPIStore]()
    
    // Handlers
    public var completionIsConnected: (() -> Void)?
    
    
    // MARK: - Class Initialization
    private init() {}
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Custom Functions
    public func connect() {
        Logger.log(message: "Success", event: .severe)
        
        if webSocket.isConnected { return }
        
        webSocket.connect()
        webSocket.delegate = WebSocketManager.instance
        
        WebSocketManager.instance.completionIsConnected = {
            guard self.requestMethodsAPIStore.count > 0 else {
                return
            }
            
//            for requestMethodAPIStore in self.requestMethodsAPIStore {
//                self.sendMessage(requestMethodAPIStore.value)
//            }
        }
    }
    
    public func disconnect() {
        Logger.log(message: "Success", event: .severe)
        
        guard webSocket.isConnected else { return }
        
        if let requestMethodAPIStore = self.requestMethodsAPIStore.first?.value {
            requestMethodAPIStore.completion((responseAPI: nil, errorAPI: ErrorAPI.responseUnsuccessful(message: "No Internet Connection")))
            self.requestMethodsAPIStore = [Int: RequestMethodAPIStore]()
        }
        
        webSocket.disconnect()
    }
    
    public func sendMessage(_ message: String) {
        Logger.log(message: "\nrequestMessage = \n\t\(message)", event: .debug)
        
        webSocket.write(string: message)
    }
    
    
    /// Send content request message
    public func sendRequest(methodAPIType: RequestMethodAPIType, completion: @escaping (ResponseAPIType) -> Void) {
        if webSocket.isConnected {
            self.sendMessage(methodAPIType.requestMessage!)
        }
            
        else {
            webSocket.connect()
            
            WebSocketManager.instance.completionIsConnected     =   {
                self.sendMessage(methodAPIType.requestMessage!)
            }
        }
        
        self.requestMethodsAPIStore[methodAPIType.id] = RequestMethodAPIStore(methodAPIType: methodAPIType.methodAPIType, completion: completion)
    }
    
    
    /**
     Checks `JSON` for an error.
     
     - Parameter json: Input response dictionary.
     - Parameter completion: Return two values:
     - Parameter codeID: Request ID.
     - Parameter hasError: Error indicator.
     
     */
    private func validate(json: [String: Any], completion: @escaping (_ codeID: Int, _ hasError: Bool) -> Void) {
        Logger.log(message: json.description, event: .debug)
        
        guard let id = json["id"] as? Int else {
            if let params = json["params"] as? Dictionary<String, String>, let paramsSecret = params["secret"] {
                Config.webSocketSecretKey = paramsSecret
            }
            
            if let method = json["method"] as? String, method == "sign" {
                self.completionIsConnected!()
            }
            
            return
        }
        
        completion(id, json["error"] != nil)
    }
    
    
    /**
     Decode blockchain response.
     
     - Parameter jsonData: The `Data` of response.
     - Parameter methodAPIType: The type of API method.
     - Returns: Return `RequestAPIType` tuple.
     
     */
    func decode(from jsonData: Data, byMethodAPIType methodAPIType: MethodAPIType) throws -> ResponseAPIType {
        do {
            Logger.log(message: "jsonData = \n\t\(String(describing: try JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [String: AnyObject]))", event: .debug)
            
            switch methodAPIType {
            case .getFeed(_):
                return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetFeedResult.self, from: jsonData), errorAPI: nil)
                
            case .getPost(_):
                return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetPostResult.self, from: jsonData), errorAPI: nil)
                
            case .getUserComments(_), .getPostComments(_):
                return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetCommentsResult.self, from: jsonData), errorAPI: nil)
                
            case .getProfile(_):
                return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetProfileResult.self, from: jsonData), errorAPI: nil)
                
            case .authorize():
                return (responseAPI: try JSONDecoder().decode(ResponseAPIAuthAuthorizeResult.self, from: jsonData), errorAPI: nil)
            }
        } catch {
            Logger.log(message: "\(error)", event: .error)
            return (responseAPI: nil, errorAPI: ErrorAPI.jsonParsingFailure(message: error.localizedDescription))
        }
    }
}


// MARK: - WebSocketDelegate
extension WebSocketManager: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        Logger.log(message: "Success", event: .severe)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        Logger.log(message: "Success", event: .severe)
        
        if let jsonData = text.data(using: .utf8), let json = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves) as! [String: Any] {
            // Check error
            self.validate(json: json, completion: { [weak self] (codeID, hasError) in
                guard let strongSelf = self else { return }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    
                    if hasError {
                        let responseAPIResultError = try jsonDecoder.decode(ResponseAPIErrorResult.self, from: jsonData)
                        strongSelf.errorAPI = ErrorAPI.requestFailed(message: responseAPIResultError.error.message.components(separatedBy: "second.end(): ").last!)
                    }
                    
                    guard let requestMethodAPIStore = strongSelf.requestMethodsAPIStore[codeID] else { return }
                    
                    let responseAPIType = try self?.decode(from:                jsonData,
                                                           byMethodAPIType:     requestMethodAPIStore.methodAPIType)
                    
                    guard let responseAPIResult = responseAPIType?.responseAPI else {
                        strongSelf.errorAPI = responseAPIType?.errorAPI ?? ErrorAPI.invalidData(message: "Response Unsuccessful")
                        
                        return requestMethodAPIStore.completion((responseAPI: nil, errorAPI: strongSelf.errorAPI))
                    }
                    
                    Logger.log(message: "\nresponseAPIResult model:\n\t\(responseAPIResult)", event: .debug)
                    
                    requestMethodAPIStore.completion((responseAPI: responseAPIResult, errorAPI: nil))
                } catch {
                    Logger.log(message: "\nResponse Unsuccessful:\n\t\(error.localizedDescription)", event: .error)
                    
                    strongSelf.errorAPI = ErrorAPI.responseUnsuccessful(message: error.localizedDescription)
                    
                    if let requestMethodAPIStore = strongSelf.requestMethodsAPIStore[codeID] {
                        requestMethodAPIStore.completion((responseAPI: nil, errorAPI: strongSelf.errorAPI))
                    }
                }
            })
        }
    }
    
    
    /// Not used
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        Logger.log(message: "Success", event: .severe)
        
        self.disconnect()
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        Logger.log(message: "Success", event: .severe)
    }
}

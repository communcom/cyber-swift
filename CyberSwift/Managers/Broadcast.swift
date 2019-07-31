//
//  Broadcast.swift
//  CyberSwift
//
//  Created by msm72 on 15.05.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation
import RxSwift

/// Type of request API
public typealias RequestMethodAPIType   =   (id: Int, requestMessage: String?, methodAPIType: MethodAPIType, errorAPI: ErrorAPI?)

/// Type of response API
public typealias ResponseAPIType        =   (responseAPI: Decodable?, errorAPI: ErrorAPI?)
public typealias ResultAPIHandler       =   (Decodable) -> Void
public typealias ErrorAPIHandler        =   (ErrorAPI) -> Void

/// Type of stored request API
public typealias RequestMethodAPIStore  =   (methodAPIType: MethodAPIType, completion: (ResponseAPIType) -> Void)


public class Broadcast {
    // MARK: - Properties
    public static let instance = Broadcast()
    
    #warning("Remove later")
    let bag = DisposeBag()
    
    // MARK: - Class Initialization
    private init() {}
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Class Functions

    /// Completion handler
    func completion<Result>(onResult: @escaping (Result) -> Void, onError: @escaping (ErrorAPI) -> Void) -> ((Result?, ErrorAPI?) -> Void) {
        return { (maybeResult, maybeError) in
            if let result = maybeResult {
                onResult(result)
            }
                
            else if let error = maybeError {
                onError(error)
            }
                
            else {
                onError(ErrorAPI.requestFailed(message: "Result not found"))
            }
        }
    }
    

    /// Generate array of new accounts
    public func generateNewTestUser(success: @escaping (ResponseAPICreateNewAccount?) -> Void) {
        //  1. Set up the HTTP request with URLSession
        let session = URLSession.shared
        
        if let url = URL(string: "http://116.203.39.126:7777/get_users") {
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    Logger.log(message: "Error create new acounts: \(error!.localizedDescription)", event: .error)
                    return success(nil)
                }
                
                do {
                    let jsonArray = try JSONDecoder().decode([ResponseAPICreateNewAccount].self, from: data!)
                    
                    if let newAccount = jsonArray.first {
                        Logger.log(message: "newAccount: \(String(describing: newAccount))", event: .debug)                        
                        return success(newAccount)
                    }
                } catch {
                    Logger.log(message: error.localizedDescription, event: .error)
                    return success(nil)
                }
            })
            
            task.resume()
        }
    }
    
    
    var currentId = 0
    /// Generating a unique ID
    //  for content:                < 100
    private func generateUniqueId(forType type: Any) -> Int {
        currentId += 1
        if currentId == 100 {
            currentId = 0
        }
        return currentId
    }
}


// MARK: - Microservices
extension Broadcast {
    /// Prepare method request
    private func prepareGETRequest(methodAPIType: MethodAPIType) -> RequestMethodAPIType {
        
        let codeID              =   generateUniqueId(forType: methodAPIType)
        let requestParamsType   =   methodAPIType.introduced()
        
        let requestAPI          =   RequestAPI(id:          codeID,
                                               method:      String(format: "%@.%@", requestParamsType.methodGroup, requestParamsType.methodName),
                                               jsonrpc:     "2.0",
                                               params:      requestParamsType.parameters)
        
        do {
            // Encode data
            let jsonEncoder = JSONEncoder()
            var jsonData = Data()
            var jsonString: String
            
            jsonData    =   try jsonEncoder.encode(requestAPI)
            jsonString  =   "\(String(data: jsonData, encoding: .utf8)!)"

            jsonString  =   jsonString
                                .replacingOccurrences(of: "[[[", with: "[[")
                                .replacingOccurrences(of: "[\"nil\"]", with: "]")
                                .replacingOccurrences(of: "\"\(Config.paginationLimit)\"", with: "\(Config.paginationLimit)")
                                .replacingOccurrences(of: "\"_", with: "")
                                .replacingOccurrences(of: "_\"", with: "")
                                .replacingOccurrences(of: "\\", with: "")
                                .replacingOccurrences(of: "\"{", with: "{")
                                .replacingOccurrences(of: "}\"}}", with: "}}}")
                                .replacingOccurrences(of: "}\"", with: "}")
                                .replacingOccurrences(of: "\"true\"", with: "true")
                                .replacingOccurrences(of: "\"false\"", with: "false")

            if jsonString.contains("registration.verify") {
                jsonString = jsonString
                                .replacingOccurrences(of: "code\":\"", with: "code\":")
                                .replacingOccurrences(of: "\"}}", with: "}}")
            }
            
            // Template: { "id": 2, "jsonrpc": "2.0", "method": "content.getProfile", "params": { "userId": "tst3uuqzetwf" }}
            return (id: codeID, requestMessage: jsonString, methodAPIType: requestParamsType.methodAPIType, errorAPI: nil)
        } catch {
            Logger.log(message: "Error: \(error.localizedDescription)", event: .error)
            
            return (id: codeID, requestMessage: nil, methodAPIType: requestParamsType.methodAPIType, errorAPI: ErrorAPI.requestFailed(message: "Broadcast, line 406: \(error.localizedDescription)"))
        }
    }
    
    /// Rx method to deal with executeGetRequest
    public func executeGetRequest(methodAPIType: MethodAPIType) -> Single<Decodable> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Prepare content request
        let requestMethodAPIType = self.prepareGETRequest(methodAPIType: methodAPIType)
        
        guard requestMethodAPIType.errorAPI == nil else {
            return .error(ErrorAPI.requestFailed(message: "Broadcast, line \(#line): \(requestMethodAPIType.errorAPI!)"))
        }
        
        Logger.log(message: "\nrequestMethodAPIType:\n\t\(requestMethodAPIType.requestMessage!)\n", event: .debug)
        
        return SocketManager.shared.sendRequest(methodAPIType: requestMethodAPIType)
            .map { responseAPIType in
                guard let responseAPI = responseAPIType.responseAPI else {
                    throw responseAPIType.errorAPI!
                }
                
                if let result = responseAPI as? ResponseAPIHasError,
                    let error = result.error{
                    var message = error.message
                    if let errorDetail = error.error {
                        message = errorDetail.what
                    }
                    throw ErrorAPI.requestFailed(message: message)
                }
                
                return responseAPI
            }
            .catchError({ (error) -> Single<Decodable> in
                if let error = error as? ErrorAPI {
                    let message = error.caseInfo.message
                    if message == "Unauthorized request: access denied" {
                        return RestAPIManager.instance.rx.authorize()
                            .flatMap {_ in self.executeGetRequest(methodAPIType: methodAPIType)}
                    }
                    
                    if message == "There is no secret stored for this channelId. Probably, client's already authorized" ||
                        message == "Secret verification failed - access denied"{
                        // retrieve secret
                        return RestAPIManager.instance.rx.generateSecret()
                            .andThen(self.executeGetRequest(methodAPIType: methodAPIType))
                    }
                }
                throw error
            })
    }
}

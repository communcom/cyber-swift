//  RestAPIManager.swift
//  CyberSwift
//
//  Created by msm72 on 12.07.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//
//  https://github.com/GolosChain/imghost
//

import Foundation
import RxSwift
import Crashlytics

public typealias RequestMethodAPIType   =   (id: Int, requestMessage: String?, methodAPIType: MethodAPIType, errorAPI: ErrorAPI?)

public class RestAPIManager {
    #if APPSTORE
        let isDebugMode = false
    #else
        let isDebugMode = true
    #endif
    
    // MARK: - Singleton
    public static let instance = RestAPIManager()
    private init() {}
    
    var currentId = 0
    
    // MARK: - Helpers
    /// Generating a unique ID for each request
    ///  for content:                < 100
    private func generateUniqueId() -> Int {
        currentId += 1
        if currentId == 100 {
            currentId = 0
        }
        return currentId
    }
    
    /// Prepare method request
    func prepareGETRequest(requestParamsType: RequestMethodParameters) -> RequestMethodAPIType {
        
        let codeID              =   generateUniqueId()
        
        let requestAPI          =   RequestAPI(id: codeID,
                                               method: String(format: "%@.%@", requestParamsType.methodGroup, requestParamsType.methodName),
                                               jsonrpc: "2.0",
                                               params: requestParamsType.parameters)
        
        do {
            // Encode data
            let jsonEncoder = JSONEncoder()
            var jsonData = Data()
            var jsonString: String
            
            jsonData    =   try jsonEncoder.encode(requestAPI)
            jsonString  =   String(data: jsonData, encoding: .utf8)!
            
            // Template: { "id": 2, "jsonrpc": "2.0", "method": "content.getProfile", "params": { "userId": "tst3uuqzetwf" }}
            return (id: codeID, requestMessage: jsonString, methodAPIType: requestParamsType.methodAPIType, errorAPI: nil)
        } catch {
            Crashlytics.sharedInstance().recordError(error)
            Logger.log(message: "Error: \(error.localizedDescription)", event: .error)
            
            return (id: codeID, requestMessage: nil, methodAPIType: requestParamsType.methodAPIType, errorAPI: ErrorAPI.requestFailed(message: "Broadcast, line 406: \(error.localizedDescription)"))
        }
    }
    
    /// Rx method to deal with executeGetRequest
    public func executeGetRequest<T: Decodable>(methodAPIType: MethodAPIType, timeout: RxSwift.RxTimeInterval = 10) -> Single<T> {
        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Prepare content request
        let requestParamsType   =   methodAPIType.introduced()
        let requestMethodAPIType = prepareGETRequest(requestParamsType: requestParamsType)

        if let error = requestMethodAPIType.errorAPI {
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Method" : methodAPIType.introduced().methodName])
            return .error(ErrorAPI.requestFailed(message: "Broadcast, line \(#line): \(error)"))
        }
        
        Logger.log(message: "\nrequestMethodAPIType:\n\t\(requestMethodAPIType.requestMessage!)\n", event: .request, apiMethod: "\(requestParamsType.methodGroup).\(requestParamsType.methodName)")
        
        return SocketManager.shared.sendRequest(methodAPIType: requestMethodAPIType, timeout: timeout)
            .catchError({ (error) -> Single<T> in
                Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: ["Method" : methodAPIType.introduced().methodName])
                if let errorAPI = error as? ErrorAPI {

                    let message = errorAPI.caseInfo.message
                    
                    if message == "Unauthorized request: access denied" {
                        return RestAPIManager.instance.authorize()
                            .flatMap {_ in self.executeGetRequest(methodAPIType: methodAPIType)}
                    }
                    
                    if message == "There is no secret stored for this channelId. Probably, client's already authorized" ||
                        message == "Secret verification failed - access denied"{
                        // retrieve secret
                        return RestAPIManager.instance.generateSecret()
                            .andThen(self.executeGetRequest(methodAPIType: methodAPIType))
                    }
                }
                                
                if let errorRx = error as? RxError {
                    switch errorRx {
                    case .timeout:
                        throw ErrorAPI.requestFailed(message: "Request has timed out")
                    default:
                        break
                    }
                }
                
                throw error
            })
            .log(method: "\(requestParamsType.methodGroup).\(requestParamsType.methodName)")
    }

    // MARK: - FACADE-SERVICE
    // API `content.waitForTransaction`
    public func waitForTransactionWith(id: String) -> Completable {

        let methodAPIType = MethodAPIType.waitForTransaction(id: id)

        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIContentWaitForTransaction>)
            .flatMapToCompletable()
    }

    // MARK: - Contract `gls.social`
    /// Posting image
    public func uploadImage(_ image: UIImage) -> Single<String> {
        return .create {single in
            DispatchQueue(label: "Uploading queue").async {
                RestAPIManager.instance.posting(image: image, responseHandling: { (url) in
                    return single(.success(url))
                }, errorHandling: { (error) in
                    return single(.error(error))
                })
            }
            
            return Disposables.create()
        }
    }
    
    public func posting(image: UIImage,
                        responseHandling:   @escaping (String) -> Void,
                        errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let resizedImage = image.resize() else { return errorHandling(ErrorAPI.invalidData(message: "Invalid Data")) }
        
        guard let imageData = resizedImage.pngData() ?? resizedImage.jpegData(compressionQuality: 1.0) else { return errorHandling(ErrorAPI.invalidData(message: "Invalid Data")) }
        
        let session             =   URLSession(configuration: .default)
        let requestURL          =   URL(string: Config.imageHost)!
        
        let request             =   NSMutableURLRequest(url: requestURL)
        request.httpMethod      =   "POST"
        
        let boundaryConstant    =   "----------------12345"
        let contentType         =   "multipart/form-data;boundary=" + boundaryConstant
        
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Create upload data to send
        let uploadData          =   NSMutableData()
        
        // Add image
        uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(String.randomString(length: 9)).png\"\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append("Content-Type: image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        uploadData.append(imageData)
        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
        
        request.httpBody        =   uploadData as Data
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, _, error) -> Void in
            guard error == nil else {
                errorHandling(ErrorAPI.responseUnsuccessful(message: "POST Request Failed"))
                return
            }
            
            let response = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            Logger.log(message: "response = \(String(describing: response))", event: .debug)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String: Any]
                
                if let imageURL = json?["url"] as? String {
                    Logger.log(message: "\nAPI `posting image` response result: \n\(imageURL)\n", event: .debug)
                    responseHandling(imageURL)
                } else {
                    Logger.log(message: "\nAPI `posting image` response error: \n\"JSON Parsing Failure\"\n", event: .error)
                    errorHandling(ErrorAPI.jsonParsingFailure(message: "JSON Parsing Failure"))
                }
            } catch {
                Logger.log(message: "\nAPI `posting image` response error: \n\"JSON Conversion Failure\"\n", event: .error)
                errorHandling(ErrorAPI.jsonConversionFailure(message: "JSON Conversion Failure"))
            }
        })
        
        task.resume()
    }
    
    // MARK: - Others
    /// get embed content
    public func getEmbed(url: String) -> Single<ResponseAPIFrameGetEmbed> {
        let methodAPIType = MethodAPIType.getEmbed(url: url)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func sendMessageIgnoreResponse(methodAPIType: MethodAPIType) {
        let requestParamsType = methodAPIType.introduced()
        let requestMethodAPIType = prepareGETRequest(requestParamsType: requestParamsType)
        SocketManager.shared.sendMessage(requestMethodAPIType.requestMessage!)
    }
}

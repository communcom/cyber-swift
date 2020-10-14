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

public class RestAPIManager {
    #if APPSTORE
        let isDebugMode = false
    #else
        let isDebugMode = true
    #endif
    
    // MARK: - Singleton
    public static let instance = RestAPIManager()
    private init() {}
    
        public lazy var markedAsViewedPosts = Set<ResponseAPIContentGetPost.Identity>()
    
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
    
    public func executeGetRequest<T: Decodable>(methodGroup: MethodAPIGroup, methodName: String, params: [String: Encodable], timeout: RxSwift.RxTimeInterval = 10, authorizationRequired: Bool = true) -> Single<T> {
        // Offline mode
        if !Config.isNetworkAvailable {
            ErrorLogger.shared.recordError(CMError.noConnection, additionalInfo: ["user": Config.currentUser?.id ?? "undefined", "method": methodGroup.rawValue + "." + methodName])
            return .error(CMError.noConnection)
        }
        let id = generateUniqueId()
        return SocketManager.shared.sendRequest(id: id, methodGroup: methodGroup, methodName: methodName, params: params, timeout: timeout, authorizationRequired: authorizationRequired)
            .catchError({ (error) -> Single<T> in
                ErrorLogger.shared.recordError(error, additionalInfo: ["user": Config.currentUser?.id ?? "undefined", "method": methodGroup.rawValue + "." + methodName])
                if let error = error as? CMError {
                    switch error {
                    case .unauthorized:
                        return RestAPIManager.instance.authorize()
                            .flatMap {_ in self.executeGetRequest(methodGroup: methodGroup, methodName: methodName, params: params, timeout: timeout, authorizationRequired: authorizationRequired)}
                    case .secretVerificationFailed:
                        // retrieve secret
                        return RestAPIManager.instance.generateSecret()
                            .andThen(self.executeGetRequest(methodGroup: methodGroup, methodName: methodName, params: params, timeout: timeout, authorizationRequired: authorizationRequired))
                    default:
                        throw error
                    }
                }
                                
                if let errorRx = error as? RxError {
                    switch errorRx {
                    case .timeout:
                        throw CMError.requestFailed(message: ErrorMessage.requestHasTimedOut.rawValue, code: 0)
                    default:
                        break
                    }
                }
                
                throw error
            })
            .log(method: "\(methodGroup).\(methodName)", id: id)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .observeOn(MainScheduler.instance)
    }

    // MARK: - FACADE-SERVICE
    // API `content.waitForTransaction`
    public func waitForTransactionWith(id: String) -> Completable {
        (executeGetRequest(methodGroup: .content, methodName: "waitForTransaction", params: ["transactionId": id], authorizationRequired: false) as Single<ResponseAPIContentWaitForTransaction>)
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
                        errorHandling:      @escaping (CMError) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(CMError.noConnection) }
        
        guard let resizedImage = image.resize() else { return errorHandling(CMError.invalidRequest(message: ErrorMessage.couldNotResizeImage.rawValue)) }
        
        guard let imageData = resizedImage.pngData() ?? resizedImage.jpegData(compressionQuality: 1.0) else { return errorHandling(CMError.invalidRequest(message: ErrorMessage.couldNotResizeImage.rawValue)) }
        
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
                errorHandling(CMError.requestFailed(message: ErrorMessage.uploadingImageFailed.rawValue, code: 0))
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
                    errorHandling(CMError.requestFailed(message: ErrorMessage.jsonParsingFailed.rawValue, code: 0))
                }
            } catch {
                ErrorLogger.shared.recordError(error, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
                Logger.log(message: "\nAPI `posting image` response error: \n\"JSON Conversion Failure\"\n", event: .error)
                errorHandling(CMError.requestFailed(message: ErrorMessage.jsonConversionFailed.rawValue, code: 0))
            }
        })
        
        task.resume()
    }
    
    // MARK: - Others
    /// get embed content
    public func getEmbed(url: String) -> Single<ResponseAPIFrameGetEmbed> {
        executeGetRequest(methodGroup: .frame, methodName: "getEmbed", params: [ "type": "oembed", "url": url])
    }
    
    public func sendMessageIgnoreResponse(methodGroup: MethodAPIGroup, methodName: String, params: [String: Encodable], authorizationRequired: Bool = true) {
        let id = generateUniqueId()
        let requestAPI = RequestAPI(
            id: id,
            method: methodGroup.rawValue + "." + methodName,
            jsonrpc: "2.0",
            params: params
        )
        
        guard let jsonData = try? JSONEncoder().encode(requestAPI),
              let message = String(data: jsonData, encoding: .utf8)
        else {
            return
        }
        
        SocketManager.shared.sendMessage(methodGroup: methodGroup, methodName: methodName, message: message, authorizationRequired: authorizationRequired)
    }
}

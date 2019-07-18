//  RestAPIManager.swift
//  CyberSwift
//
//  Created by msm72 on 12.07.2018.
//  Copyright © 2018 golos. All rights reserved.
//
//  https://github.com/GolosChain/imghost
//

import eosswift
import Foundation

public class RestAPIManager {
    #warning("remove debug mode")
    let isDebugMode = true
    
    // MARK: - Properties
    public static let instance = RestAPIManager()
    
    // MARK: - FACADE-SERVICE
    // API `content.getProfile`
    public func getProfile(userID:          String,
                           appProfileType:  AppProfileType = .cyber,
                           completion:      @escaping (ResponseAPIContentGetProfile?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getProfile(userID: userID, appProfileType: appProfileType)

        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let profileResult = responseAPIResult as? ResponseAPIContentGetProfileResult, let result = profileResult.result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIContentGetProfileResult).error
                                                    Logger.log(message: "\nAPI `content.getProfile` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `content.getProfile` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `content.getProfile` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }

    // API `content.getFeed`
    public func loadFeed(typeMode:                  FeedTypeMode = .community,
                         userID:                    String? = nil,
                         communityID:               String? = nil,
                         timeFrameMode:             FeedTimeFrameMode = .day,
                         sortMode:                  FeedSortMode = .popular,
                         paginationLimit:           Int8 = Config.paginationLimit,
                         paginationSequenceKey:     String? = nil,
                         completion:                @escaping (ResponseAPIContentGetFeed?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getFeed(typeMode: typeMode, userID: userID, communityID: communityID, timeFrameMode: timeFrameMode, sortMode: sortMode, paginationSequenceKey: paginationSequenceKey)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIContentGetFeedResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIContentGetFeedResult).error
                                                    Logger.log(message: "\nAPI `content.getFeed` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `content.getFeed` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `content.getPost`
    public func loadPost(userID:        String = Config.currentUser?.id ?? "Cyber",
                         permlink:      String,
                         completion:    @escaping (ResponseAPIContentGetPost?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getPost(userID: userID, permlink: permlink)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIContentGetPostResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIContentGetPostResult).error
                                                    Logger.log(message: "\nAPI `content.getPost` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `content.getPost` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `content.getPost` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `content.getComments` by user
    public func loadUserComments(nickName:                  String? = Config.currentUser?.id,
                                 sortMode:                  CommentSortMode = .time,
                                 paginationLimit:           Int8 = Config.paginationLimit,
                                 paginationSequenceKey:     String? = nil,
                                 completion:                @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getUserComments(nickName: nickName ?? "Cyber", sortMode: sortMode, paginationSequenceKey: paginationSequenceKey)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIContentGetCommentsResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIContentGetCommentsResult).error
                                                    Logger.log(message: "\nAPI `content.getComments` by user response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `content.getComments` by user response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `content.getComments` by post
    public func loadPostComments(nickName:                  String = Config.currentUser?.id ?? "Cyber",
                                 permlink:                  String,
                                 sortMode:                  CommentSortMode = .time,
                                 paginationLimit:           Int8 = Config.paginationLimit,
                                 paginationSequenceKey:     String? = nil,
                                 completion:                @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getPostComments(userNickName:             nickName,
                                                          permlink:                 permlink,
                                                          sortMode:                 sortMode,
                                                          paginationSequenceKey:    paginationSequenceKey)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIContentGetCommentsResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIContentGetCommentsResult).error
                                                    Logger.log(message: "\nAPI `content.getComments` by post response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `content.getComments` by post response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `content.waitForTransaction`
    public func waitForTransactionWith(id: String, completion: @escaping (ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(ErrorAPI.disableInternetConnection(message: nil)) }
        let methodAPIType = MethodAPIType.waitForTransaction(id: id)
        
        Broadcast.instance.executeGETRequest(byContentAPIType: methodAPIType, onResult: { (responseAPIResult) in
            guard let result = (responseAPIResult as! ResponseAPIContentWaitForTransactionResult).result,
                result.status == "OK"
            else {
                if let responseAPIError = (responseAPIResult as! ResponseAPIContentWaitForTransactionResult).error {
                    Logger.log(message: "\nAPI `content.waitForTransaction` response mapping error: \n\(responseAPIError.message)\n", event: .error)
                    return completion(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError.message)"))
                }
                return completion(ErrorAPI.requestFailed(message: "Unknown error"))
            }
            
            Logger.log(message: "\nAPI `content.waitForTransaction` response result: \n\(result)\n", event: .debug)
            return completion(nil)
            
        }, onError: {error in
            Logger.log(message: "\nAPI `content.waitForTransaction` response error: \n\(error)\n", event: .error)
            return completion(error)
        })
    }
    
    // API `push.historyFresh`
    public func getPushHistoryFresh(completion: @escaping (ResponseAPIPushHistoryFresh?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getPushHistoryFresh
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIPushHistoryFreshResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIPushHistoryFreshResult).error
                                                    Logger.log(message: "\nAPI `push.historyFresh` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `push.historyFresh` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `push.historyFresh` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `onlineNotify.history`
    public func getOnlineNotifyHistory(fromId:              String? = nil,
                                       paginationLimit:     Int8 = Config.paginationLimit,
                                       markAsViewed:        Bool = false,
                                       freshOnly:           Bool = false,
                                       completion:          @escaping (ResponseAPIOnlineNotifyHistory?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistory(fromId: fromId, paginationLimit: paginationLimit, markAsViewed: markAsViewed, freshOnly: freshOnly)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                guard let result = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryResult).error
                                                    Logger.log(message: "\nAPI `onlineNotify.history` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `onlineNotify.history` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `onlineNotify.history` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `onlineNotify.historyFresh`
    public func getOnlineNotifyHistoryFresh(completion: @escaping (ResponseAPIOnlineNotifyHistoryFresh?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistoryFresh
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryFreshResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryFreshResult).error
                                                    Logger.log(message: "\nAPI `onlineNotify.historyFresh` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `onlineNotify.historyFresh` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `onlineNotify.historyFresh` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `notify.markAllAsViewed`
    public func notifyMarkAllAsViewed(completion: @escaping (ResponseAPINotifyMarkAllAsViewed?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.notifyMarkAllAsViewed
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPINotifyMarkAllAsViewedResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPINotifyMarkAllAsViewedResult).error
                                                    Logger.log(message: "\nAPI `notify.markAllAsViewed` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `notify.markAllAsViewed` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `notify.markAllAsViewed` response error = \(errorAPI.localizedDescription)\n", event: .error)
                                                completion(nil, errorAPI)
        })
    }
    
    // API `notify.markAsRead`
    public func markAsRead(notifies:            [String],
                           responseHandling:    @escaping (ResponseAPIMarkNotifiesAsRead) -> Void,
                           errorHandling:       @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.markAsRead(notifies: notifies)

        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIMarkNotifiesAsReadResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIMarkNotifiesAsReadResult).error
                                                    Logger.log(message: "\nAPI `notify.markAsRead` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `notify.markAsRead` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `notify.markAsRead` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }
    
    // API basic `options.set`
    public func setBasicOptions(nsfwContent:        NsfwContentMode,
                                responseHandling:   @escaping (ResponseAPISetOptionsBasic) -> Void,
                                errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPISetOptionsBasicResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPISetOptionsBasicResult).error
                                                    Logger.log(message: "\nAPI basic \'options.set\' response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI basic `options.set` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI basic `options.set` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }
    
    // API `meta.recordPostView`
    public func recordPostView(permlink:            String,
                               responseHandling:    @escaping (ResponseAPIMetaRecordPostView) -> Void,
                               errorHandling:       @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.recordPostView(permlink: permlink)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIMetaRecordPostViewResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIMetaRecordPostViewResult).error
                                                    Logger.log(message: "\nAPI `meta.recordPostView` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `meta.recordPostView` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `meta.recordPostView` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }
    
    // API `favorites.get`
    public func getFavorites(responseHandling:  @escaping (ResponseAPIGetFavorites) -> Void,
                             errorHandling:     @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.getFavorites
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { responseAPIResult in
                                                guard let result = (responseAPIResult as! ResponseAPIGetFavoritesResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIGetFavoritesResult).error
                                                    Logger.log(message: "\nAPI `favorites.get` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `favorites.get` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { errorAPI in
                                                Logger.log(message: "\nAPI `favorites.get` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }

    // API `favorites.add`
    public func addFavorites(permlink:          String,
                             responseHandling:  @escaping (ResponseAPIAddFavorites) -> Void,
                             errorHandling:     @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.addFavorites(permlink: permlink)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { responseAPIResult in
                                                guard let result = (responseAPIResult as! ResponseAPIAddFavoritesResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIAddFavoritesResult).error
                                                    Logger.log(message: "\nAPI `favorites.add` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `favorites.add` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { errorAPI in
                                                Logger.log(message: "\nAPI `favorites.add` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }

    // API `favorites.remove`
    public func removeFavorites(permlink:          String,
                                responseHandling:  @escaping (ResponseAPIRemoveFavorites) -> Void,
                                errorHandling:     @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }
        
        let methodAPIType = MethodAPIType.removeFavorites(permlink: permlink)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { responseAPIResult in
                                                guard let result = (responseAPIResult as! ResponseAPIRemoveFavoritesResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIRemoveFavoritesResult).error
                                                    Logger.log(message: "\nAPI `favorites.remove` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `favorites.remove` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { errorAPI in
                                                Logger.log(message: "\nAPI `favorites.remove` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }

    //  MARK: - Contract `gls.social`
    /// Posting image
    public func posting(image:              UIImage,
                        responseHandling:   @escaping (String) -> Void,
                        errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let resizedImage = image.resize(to: 2) else { return errorHandling(ErrorAPI.invalidData(message: "Invalid Data")) }
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 1.0) ?? resizedImage.pngData() else { return errorHandling(ErrorAPI.invalidData(message: "Invalid Data")) }
        
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
}

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
import RxSwift

public class RestAPIManager {
    #warning("remove debug mode")
    let isDebugMode = true
    
    // MARK: - Properties
    public static let instance = RestAPIManager()
    
    // MARK: - FACADE-SERVICE
    // API `content.getProfile`
    public func getProfile(
        userID:          String?,
        username:        String? = nil,
        appProfileType:  AppProfileType = .cyber
    ) -> Single<ResponseAPIContentGetProfile> {
        
        if userID == nil && username == nil {
            return .error(ErrorAPI.requestFailed(message: "userID or username is missing"))
        }
        
        let methodAPIType = MethodAPIType.getProfile(userID: userID, username: username, appProfileType: appProfileType)

        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.getProfile")
            .map {result in
                guard let result = (result as? ResponseAPIContentGetProfileResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
            .catchError({ (error) in
                // if tried fetching username
                if username != nil {throw error}
                
                // retry fetching with username
                if let error = error as? ErrorAPI {
                    let message = error.caseInfo.message
                    if message == "Not found" {
                        return self.getProfile(userID: nil, username: userID)
                    }
                }
                throw error
            })
    }

    // API `content.getFeed`
    public func loadFeed(
        typeMode:                  FeedTypeMode = .community,
        userID:                    String? = nil,
        communityID:               String? = nil,
        timeFrameMode:             FeedTimeFrameMode = .day,
        sortMode:                  FeedSortMode = .popular,
        paginationLimit:           Int8 = Config.paginationLimit,
        paginationSequenceKey:     String? = nil
    ) -> Single<ResponseAPIContentGetFeed> {
        
        let methodAPIType = MethodAPIType.getFeed(typeMode: typeMode, userID: userID, communityID: communityID, timeFrameMode: timeFrameMode, sortMode: sortMode, paginationSequenceKey: paginationSequenceKey)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.getFeed")
            .map {result in
                guard let result = (result as? ResponseAPIContentGetFeedResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `content.getPost`
    public func loadPost(
        userID:        String = Config.currentUser?.id ?? "Cyber",
        permlink:      String
    ) -> Single<ResponseAPIContentGetPost> {
        
        let methodAPIType = MethodAPIType.getPost(userID: userID, permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.getPost")
            .map {result in
                guard let result = (result as? ResponseAPIContentGetPostResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `content.getComments` by user
    public func loadUserComments(
        nickName:                  String? = Config.currentUser?.id,
        sortMode:                  CommentSortMode = .time,
        paginationLimit:           Int8 = Config.paginationLimit,
        paginationSequenceKey:     String? = nil
    ) -> Single<ResponseAPIContentGetComments> {
        
        let methodAPIType = MethodAPIType.getUserComments(
            nickName: nickName ?? "Cyber",
            sortMode: sortMode,
            limit: paginationLimit,
            paginationSequenceKey: paginationSequenceKey)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.getComments")
            .map {result in
                guard let result = (result as? ResponseAPIContentGetCommentsResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `content.getComments` by post
    public func loadPostComments(
        nickName:                  String = Config.currentUser?.id ?? "Cyber",
        permlink:                  String,
        sortMode:                  CommentSortMode = .time,
        paginationLimit:           Int8 = Config.paginationLimit,
        paginationSequenceKey:     String? = nil
    ) -> Single<ResponseAPIContentGetComments> {
        
        let methodAPIType = MethodAPIType.getPostComments(userNickName:             nickName,
                                                          permlink:                 permlink,
                                                          sortMode:                 sortMode,
                                                          limit: paginationLimit,
                                                          paginationSequenceKey:    paginationSequenceKey)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.getComments (by post)")
            .map {result in
                guard let result = (result as? ResponseAPIContentGetCommentsResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `content.waitForTransaction`
    public func waitForTransactionWith(id: String) -> Completable {
        
        let methodAPIType = MethodAPIType.waitForTransaction(id: id)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "content.waitForTransaction")
            .flatMapCompletable({ (result) -> Completable in
                guard ((result as? ResponseAPIContentWaitForTransactionResult)?.result) != nil else {
                    throw ErrorAPI.unknown
                }
                return .empty()
            })
    }
    
    // API `push.historyFresh`
    public func getPushHistoryFresh() -> Single<ResponseAPIPushHistoryFresh> {
        
        let methodAPIType = MethodAPIType.getPushHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "push.historyFresh")
            .map {result in
                guard let result = (result as? ResponseAPIPushHistoryFreshResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `onlineNotify.history`
    public func getOnlineNotifyHistory(
        fromId:              String? = nil,
        paginationLimit:     Int8 = Config.paginationLimit,
        markAsViewed:        Bool = false,
        freshOnly:           Bool = false
    ) -> Single<ResponseAPIOnlineNotifyHistory> {
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistory(fromId: fromId, paginationLimit: paginationLimit, markAsViewed: markAsViewed, freshOnly: freshOnly)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "onlineNotify.history")
            .map {result in
                guard let result = (result as? ResponseAPIOnlineNotifyHistoryResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `onlineNotify.historyFresh`
    public func getOnlineNotifyHistoryFresh() -> Single<ResponseAPIOnlineNotifyHistoryFresh> {
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "onlineNotify.historyFresh")
            .map {result in
                guard let result = (result as? ResponseAPIOnlineNotifyHistoryFreshResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `notify.markAllAsViewed`
    public func notifyMarkAllAsViewed() -> Single<ResponseAPINotifyMarkAllAsViewed> {
        
        let methodAPIType = MethodAPIType.notifyMarkAllAsViewed
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "notify.markAllAsViewed")
            .map {result in
                guard let result = (result as? ResponseAPINotifyMarkAllAsViewedResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `notify.markAsRead`
    public func markAsRead(notifies: [String]) -> Single<ResponseAPIMarkNotifiesAsRead> {
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.markAsRead(notifies: notifies)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "notify.markAsRead")
            .map {result in
                guard let result = (result as? ResponseAPIMarkNotifiesAsReadResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }

        
    }
    
    // API basic `options.set`
    public func setBasicOptions(nsfwContent: NsfwContentMode) -> Single<ResponseAPISetOptionsBasic> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "options.set")
            .map {result in
                guard let result = (result as? ResponseAPISetOptionsBasicResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }
    
    // API `meta.recordPostView`
    public func recordPostView(permlink: String) -> Single<ResponseAPIMetaRecordPostView> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.recordPostView(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "meta.recordPostView")
            .map {result in
                guard let result = (result as? ResponseAPIMetaRecordPostViewResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
        }
        
    }
    
    // API `favorites.get`
    public func getFavorites() -> Single<ResponseAPIGetFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.getFavorites
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "favorites.get")
            .map {result in
                guard let result = (result as? ResponseAPIGetFavoritesResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
    }

    // API `favorites.add`
    public func addFavorites(permlink: String) -> Single<ResponseAPIAddFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.addFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "favorites.add")
            .map {result in
                guard let result = (result as? ResponseAPIAddFavoritesResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
        }
    }

    // API `favorites.remove`
    public func removeFavorites(permlink: String) -> Single<ResponseAPIRemoveFavorites> {// Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}
        
        let methodAPIType = MethodAPIType.removeFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
            .log(method: "favorites.remove")
            .map {result in
                guard let result = (result as? ResponseAPIRemoveFavoritesResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
        }
    }

    //  MARK: - Contract `gls.social`
    /// Posting image
    public func posting(image:              UIImage,
                        responseHandling:   @escaping (String) -> Void,
                        errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let resizedImage = image.resize(to: 2) else { return errorHandling(ErrorAPI.invalidData(message: "Invalid Data")) }
        
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
    
    //  MARK: - Others
    /// get embed content
    public func getEmbed(url: String) -> Single<ResponseAPIFrameGetEmbed> {
        let methodAPIType = MethodAPIType.getEmbed(url: url)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "frame.getEmbed")
            .map {result in
                guard let result = (result as? ResponseAPIFrameGetEmbedResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
        }
    }
}

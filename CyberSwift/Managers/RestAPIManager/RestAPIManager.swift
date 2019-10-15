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
    // API `content.resolveProfile`
    public func resolveProfile(username: String) -> Single<ResponseAPIContentResolveProfile> {
        let methodAPIType = MethodAPIType.resolveProfile(username: username)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `content.getProfile`
    public func getProfile(
        user:        String? = nil,
        appProfileType:  AppProfileType = .cyber
    ) -> Single<ResponseAPIContentGetProfile> {
        
        if user == nil {
            return .error(ErrorAPI.requestFailed(message: "userID or username is missing"))
        }
        
        let methodAPIType = MethodAPIType.getProfile(user: user)

        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }

    // API `content.getPosts`
    public func getPosts(
        userId:         String? = Config.currentUser?.id,
        communityId:    String,
        allowNsfw:      Bool = false,
        type:           FeedTypeMode = .community,
        sortBy:         FeedSortMode = .time,
        limit:          UInt = UInt(Config.paginationLimit),
        offset:         UInt = 0
    ) -> Single<ResponseAPIContentGetPosts>
    {
        let methodAPIType = MethodAPIType.getPosts(userId: userId, communityId: communityId, allowNsfw: allowNsfw, type: type, sortBy: sortBy, limit: limit, offset: offset)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `content.getPost`
    public func loadPost(permlink: String, communityId: String) -> Single<ResponseAPIContentGetPost> {
        
        let methodAPIType = MethodAPIType.getPost(permlink: permlink, communityId: communityId)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `content.getComments` by user
    public func loadUserComments(
        sortBy: CommentSortMode = .time,
        sequenceKey: String?    = nil,
        limit: Int8             = Config.paginationLimit,
        userId: String?         = Config.currentUser?.id
    ) -> Single<ResponseAPIContentGetComments> {
        
        let methodAPIType = MethodAPIType.getComments(
            sortBy: sortBy,
            sequenceKey: sequenceKey,
            limit: limit,
            type: .user,
            userId: userId ?? "",
            permlink: nil,
            communityId: nil,
            communityAlias: nil,
            parentComment: nil)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `content.getComments` by post
    public func loadPostComments(
        sortBy: CommentSortMode         = .time,
        sequenceKey: String?            = nil,
        limit: Int8                     = Config.paginationLimit,
        userId: String?                 = Config.currentUser?.id,
        permlink: String,
        communityId: String?            = nil,
        communityAlias: String?         = nil,
        parentCommentUserId: String?    = nil,
        parentCommentPermlink: String?  = nil
    ) -> Single<ResponseAPIContentGetComments> {
        
        var parentComment: [String: String]?
        if let parentCommentUserId = parentCommentUserId,
            let parentCommentPermlink = parentCommentPermlink
        {
            parentComment = [
                "userId":   parentCommentUserId,
                "permlink": parentCommentPermlink
            ]
        }
        
        let methodAPIType = MethodAPIType.getComments(
            sortBy: sortBy,
            sequenceKey: sequenceKey,
            limit: limit,
            type: .post,
            userId: userId ?? "",
            permlink: permlink,
            communityId: communityId,
            communityAlias: communityAlias,
            parentComment: parentComment)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `content.waitForTransaction`
    public func waitForTransactionWith(id: String) -> Completable {
        
        let methodAPIType = MethodAPIType.waitForTransaction(id: id)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType) as Single<ResponseAPIContentWaitForTransaction>)
            .flatMapToCompletable()
    }
    
    // API `push.historyFresh`
    public func getPushHistoryFresh() -> Single<ResponseAPIPushHistoryFresh> {
        
        let methodAPIType = MethodAPIType.getPushHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
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
    }
    
    // API `onlineNotify.historyFresh`
    public func getOnlineNotifyHistoryFresh() -> Single<ResponseAPIOnlineNotifyHistoryFresh> {
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `notify.markAllAsViewed`
    public func notifyMarkAllAsViewed() -> Single<ResponseAPINotifyMarkAllAsViewed> {
        
        let methodAPIType = MethodAPIType.notifyMarkAllAsViewed
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `notify.markAsRead`
    public func markAsRead(notifies: [String]) -> Single<ResponseAPIMarkNotifiesAsRead> {
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.markAsRead(notifies: notifies)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API basic `options.set`
    public func setBasicOptions(nsfwContent: NsfwContentMode) -> Single<ResponseAPISetOptionsBasic> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `meta.recordPostView`
    public func recordPostView(permlink: String) -> Single<ResponseAPIMetaRecordPostView> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.recordPostView(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    // API `favorites.get`
    public func getFavorites() -> Single<ResponseAPIGetFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.getFavorites
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }

    // API `favorites.add`
    public func addFavorites(permlink: String) -> Single<ResponseAPIAddFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.addFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }

    // API `favorites.remove`
    public func removeFavorites(permlink: String) -> Single<ResponseAPIRemoveFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}
        
        let methodAPIType = MethodAPIType.removeFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType:  methodAPIType)
    }
    
    //  MARK: - Communities
    public func getCommunity(id: String) -> Single<ResponseAPIContentGetCommunity> {
        
        let methodAPIType = MethodAPIType.getCommunity(id: id)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getCommunities(
        type: GetCommunitiesType,
        userId: String? = Config.currentUser?.id,
        offset: Int,
        limit: Int = 10
    ) -> Single<ResponseAPIContentGetCommunities> {
        
        let methodAPIType = MethodAPIType.getCommunities(type: type, userId: userId, offset: offset, limit: 10)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
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
    }
}

//  RestAPIManager.swift
//  CyberSwift
//
//  Created by msm72 on 12.07.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import Foundation

public class RestAPIManager {
    // MARK: - Properties
    public static let instance = RestAPIManager()


    // MARK: - Class Initialization
    private init() {}
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Class Functions
    
    /// API `content.getProfile`
    public func loadUserProfile(byNickName nickName: String, completion: @escaping (ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getProfile(nickNames: nickName)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                    
                                                    guard (responseAPIResult as! ResponseAPIContentGetProfileResult).result == nil else {
                                                        completion(ErrorAPI.requestFailed(message: "User \(nickName) profile is not found."))
                                                        return
                                                    }
                                                                                                        
                                                    completion(nil)
            },
                                                 onError: { errorAPI in
                                                    Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                    
                                                    completion(errorAPI)
            })
        }
            
        // Offline mode
        else {
            completion(ErrorAPI.disableInternetConnection())
        }
    }
    
    
    /// API `content.getFeed`
    public func loadFeed(typeMode: FeedTypeMode = .community, userID: String? = nil, communityID: String? = nil, timeFrameMode: FeedTimeFrameMode = .day, sortMode: FeedSortMode = .popular, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetFeed?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getFeed(typeMode: typeMode, userID: userID, communityID: communityID, timeFrameMode: timeFrameMode, sortMode: sortMode, paginationLimit: paginationLimit, paginationSequenceKey: paginationSequenceKey)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIContentGetFeedResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'content.getFeed\' have error: \((responseAPIResult as! ResponseAPIContentGetProfileResult).error!.message)"))
                                                        return
                                                    }
                                                    
                                                    completion(result, nil)
            },
                                                 onError: { errorAPI in
                                                    Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                    
                                                    completion(nil, errorAPI)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection())
        }
    }
    
    
    /// API `content.getPost`
    public func loadPost(userID: String = Config.currentUser.nickName, permlink: String, refBlockNum: UInt64, completion: @escaping (ResponseAPIContentGetPost?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getPost(userID: userID, permlink: permlink, refBlockNum: refBlockNum)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIContentGetPostResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'content.getPost\' have error: \((responseAPIResult as! ResponseAPIContentGetProfileResult).error!.message)"))
                                                        return
                                                    }
                                                    
                                                    completion(result, nil)
            },
                                                 onError: { errorAPI in
                                                    Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                    
                                                    completion(nil, errorAPI)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection())
        }
    }
    
    
    /// API `content.getComments` by user
    public func loadUserComments(nickName: String = Config.currentUser.nickName, sortMode: CommentSortMode = .time, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetPost?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getUserComments(nickName: nickName, sortMode: sortMode, paginationLimit: paginationLimit, paginationSequenceKey: paginationSequenceKey)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIContentGetPostResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API user \'content.getComments\' have error: \((responseAPIResult as! ResponseAPIContentGetProfileResult).error!.message)"))
                                                        return
                                                    }
                                                    
                                                    completion(result, nil)
            },
                                                 onError: { errorAPI in
                                                    Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                    
                                                    completion(nil, errorAPI)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection())
        }
    }
}

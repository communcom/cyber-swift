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
    
    /// API `auth.authorize`
    public func authorize(userNickName: String, userActiveKey: String, completion: @escaping (ResponseAPIAuthAuthorize?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            RestAPIManager.instance.generateSecret(completion: { (generatedSecret, errorAPI) in
                guard errorAPI == nil else {
                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                    
                    completion(nil, errorAPI)
                    
                    return
                }
                
                Logger.log(message: generatedSecret!.secret, event: .debug)
                
                Config.webSocketSecretKey = generatedSecret!.secret
                
                let methodAPIType = MethodAPIType.authorize(nickName: userNickName, activeKey: userActiveKey)
                
                Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                     onResult:          { responseAPIResult in
                                                        Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                        
                                                        guard let result = (responseAPIResult as! ResponseAPIAuthAuthorizeResult).result else {
                                                            completion(nil, ErrorAPI.requestFailed(message: "API \'auth.authorize\' have error: \((responseAPIResult as! ResponseAPIAuthAuthorizeResult).error!.message)"))
                                                            return
                                                        }
                                                        
                                                        completion(result, nil)
                },
                                                     onError: { errorAPI in
                                                        Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                        
                                                        completion(nil, errorAPI)
                })
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// API `auth.generateSecret`
    private func generateSecret(completion: @escaping (ResponseAPIAuthGenerateSecret?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.generateSecret
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIAuthGenerateSecretResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'auth.generateSecret\' have error: \((responseAPIResult as! ResponseAPIAuthGenerateSecretResult).error!.message)"))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// API `content.getProfile`
    public func loadUserProfile(byNickName nickName: String, completion: @escaping (ResponseAPIContentGetProfile?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getProfile(nickNames: nickName)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let profileResult = responseAPIResult as? ResponseAPIContentGetProfileResult, let result = profileResult.result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "User \(nickName) profile is not found."))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
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
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'content.getFeed\' have error: \((responseAPIResult as! ResponseAPIContentGetFeedResult).error!.message)"))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
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
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'content.getPost\' have error: \((responseAPIResult as! ResponseAPIContentGetPostResult).error!.message)"))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// API `content.getComments` by user
    public func loadUserComments(nickName: String = Config.currentUser.nickName, sortMode: CommentSortMode = .time, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getUserComments(nickName: nickName, sortMode: sortMode, paginationLimit: paginationLimit, paginationSequenceKey: paginationSequenceKey)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIContentGetCommentsResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API user \'content.getComments\' have error: \((responseAPIResult as! ResponseAPIContentGetCommentsResult).error!.message)"))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// API `content.getComments` by post
    public func loadPostComments(nickName: String = Config.currentUser.nickName, permlink: String, refBlockNum: UInt64, sortMode: CommentSortMode = .time, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getPostComments(userNickName:             nickName,
                                                              permlink:                 permlink,
                                                              refBlockNum:              refBlockNum,
                                                              sortMode:                 sortMode,
                                                              paginationLimit:          paginationLimit,
                                                              paginationSequenceKey:    paginationSequenceKey)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIContentGetCommentsResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'content.getComments\' have error: \((responseAPIResult as! ResponseAPIContentGetCommentsResult).error!.message)"))
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
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
}

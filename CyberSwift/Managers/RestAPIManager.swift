//  RestAPIManager.swift
//  CyberSwift
//
//  Created by msm72 on 12.07.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import eosswift
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
                                                        
                                                        // Save in Keychain
                                                        _ = KeychainManager.save(data: [Config.currentUserNickNameKey: userNickName], userNickName: Config.currentUserNickNameKey)
                                                        _ = KeychainManager.save(data: [Config.currentUserActiveKey: userActiveKey], userNickName: Config.currentUserActiveKey)
                                                        
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
            let methodAPIType = MethodAPIType.getFeed(typeMode: typeMode, userID: userID, communityID: communityID, timeFrameMode: timeFrameMode, sortMode: sortMode, paginationSequenceKey: paginationSequenceKey)
            
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
    public func loadPost(userID: String = Config.currentUser.nickName ?? "Cyber", permlink: String, refBlockNum: UInt64, completion: @escaping (ResponseAPIContentGetPost?, ErrorAPI?) -> Void) {
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
    public func loadUserComments(nickName: String = Config.currentUser.nickName ?? "Cyber", sortMode: CommentSortMode = .time, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getUserComments(nickName: nickName, sortMode: sortMode, paginationSequenceKey: paginationSequenceKey)
            
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
    public func loadPostComments(nickName: String = Config.currentUser.nickName ?? "Cyber", permlink: String, refBlockNum: UInt64, sortMode: CommentSortMode = .time, paginationLimit: Int8 = Config.paginationLimit, paginationSequenceKey: String? = nil, completion: @escaping (ResponseAPIContentGetComments?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getPostComments(userNickName:             nickName,
                                                              permlink:                 permlink,
                                                              refBlockNum:              refBlockNum,
                                                              sortMode:                 sortMode,
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
    
    
    /// EOS: contract `gls.publish`, actions `upvote`, `downvote`, `unvote`
    public func message(voteType: VoteType, author: String, permlink: String, weight: Int16? = 0, refBlockNum: UInt64 = 0, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            EOSManager.message(voteType:        voteType,
                               author:          author,
                               permlink:        permlink,
                               weight:          voteType == .unvote ? 0 : 10_000,
                               refBlockNum:     refBlockNum,
                               completion:      { (response, error) in
                                guard error == nil else {
                                    completion(nil, ErrorAPI.responseUnsuccessful(message: error!.localizedDescription))
                                    return
                                }
                                
                                completion(response, nil)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// EOS: contract `gls.publish`, action `createmssg`
    public func publish(message: String, headline: String? = "", parentData: ParentData? = nil, tags: [EOSTransaction.Tags]?, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            EOSManager.publish(message:     "This is my next test post in EOS...",
                               headline:    String(format: "Test Post Title %i", arc4random_uniform(100)),
                               tags:        tags,
                               completion:  { (response, error) in
                                guard error == nil else {
                                    completion(nil, ErrorAPI.responseUnsuccessful(message: error!.localizedDescription))
                                    return
                                }
                                
                                completion(response, nil)

//                                if response!.success, response!.statusCode == 202, let refBlockNum = res, let permlink = response?.body?.processed.action_traces.first?.act.data["permlink"]?.jsonValue as? String {
//                                    print(permlink)
//                                    self.createCommentMessage(parentData: ParentData(refBlockNum: UInt64, permlink: permlink))
//                                    //                                        self.votePost(permlink: permlink)
//                                }
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// EOS: contract `gls.publish`, action `updatemssg`
    public func updateMessage(author: String?, permlink: String, message: String, parentData: ParentData?, refBlockNum: UInt64, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(authorValue:           author ?? Config.currentUser.nickName ?? "Cyberway",
                                                                     messagePermlink:       permlink,
                                                                     parentDataValue:       parentData,
                                                                     refBlockNumValue:      refBlockNum,
                                                                     bodymssgValue:         message)

            EOSManager.update(messageArgs:  messageUpdateArgs,
                              completion:   { (response, error) in
                                guard error == nil else {
                                    completion(nil, ErrorAPI.responseUnsuccessful(message: error!.localizedDescription))
                                    return
                                }
                                
                                completion(response, nil)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
    
    
    /// EOS: contract `gls.publish`, action `deletemssg`
    public func deleteMessage(author: String, permlink: String, refBlockNum: UInt64, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue:           author,
                                                                     messagePermlink:       permlink,
                                                                     refBlockNumValue:      refBlockNum)

            EOSManager.delete(messageArgs:  messageDeleteArgs,
                              completion:   { (response, error) in
                                guard error == nil else {
                                    completion(nil, ErrorAPI.responseUnsuccessful(message: error!.localizedDescription))
                                    return
                                }
                                
                                completion(response, nil)
            })
        }
            
        // Offline mode
        else {
            completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
    }
}

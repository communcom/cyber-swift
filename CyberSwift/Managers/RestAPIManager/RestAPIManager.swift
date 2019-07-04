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

public enum NoticeType {
    case push
    case notify
}

public class RestAPIManager {
    #warning("remove debug mode")
    let isDebugMode = true
    
    // MARK: - Properties
    public static let instance = RestAPIManager()
    
    // MARK: - FACADE-SERVICE
    // API `auth.authorize`
    public func authorize(userID:               String,
                          userActiveKey:        String,
                          responseHandling:     @escaping (ResponseAPIAuthAuthorize) -> Void,
                          errorHandling:        @escaping (Error) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.authorize(userID: userID, activeKey: userActiveKey)
        
        Broadcast.instance.executeGETRequest(
            byContentAPIType: methodAPIType,
            onResult: { responseAPIResult in
                guard let result = (responseAPIResult as! ResponseAPIAuthAuthorizeResult).result
                    else {
                        let responseAPIError = (responseAPIResult as! ResponseAPIAuthAuthorizeResult).error
                        
                        Logger.log(message: "\nAPI `auth.authorize` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                        
                        return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                }
                
                DispatchQueue.main.async(execute: {
                    // Log result
                    Logger.log(message: "\nAPI `auth.authorize` response result: \n\(responseAPIResult)\n", event: .debug)
                    
                    // Save to UserDefault
                    UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
                    
                    // Save in Keychain
                    do {
                        try KeychainManager.deleteUser()
                        try KeychainManager.save(data: [
                            Config.currentUserIDKey:            userID,
                            Config.currentUserNameKey:          result.displayName,
                            Config.currentUserPublicActiveKey:  userActiveKey
                            ])
                        
                        // Save in iCloud key-value
                        iCloudManager.saveUser()
                        
                        // API `push.notifyOn`
                        if let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String {
                            RestAPIManager.instance.pushNotifyOn(
                                fcmToken:          fcmToken,
                                responseHandling:  { response in
                                    Logger.log(message: response.status, event: .severe)
                            },
                                errorHandling:     { errorAPI in
                                    Logger.log(message: errorAPI.caseInfo.message, event: .error)
                            })
                        }
                        
                        responseHandling(result)
                        
                    } catch {
                        errorHandling(error)
                        return
                    }
                })
        },
            onError:           { (errorAPI) in
                Logger.log(message: "\nAPI `auth.authorize` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                errorHandling(errorAPI)
        })
    }

    
    
    // API `auth.generateSecret`
    private func generateSecret(completion: @escaping (ResponseAPIAuthGenerateSecret?, ErrorAPI?) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.generateSecret
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIAuthGenerateSecretResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIAuthGenerateSecretResult).error
                                                    Logger.log(message: "\nAPI `auth.generateSecret` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return completion(nil, ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `auth.generateSecret` response result: \n\(responseAPIResult)\n", event: .debug)
                                                completion(result, nil)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `auth.generateSecret` response error: \n\(errorAPI.localizedDescription)\n", event: .debug)
                                                
                                                completion(nil, errorAPI)
        })
    }
    
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
    
    // API `push.notifyOn`
    public func pushNotifyOn(fcmToken:             String,
                              responseHandling:     @escaping (ResponseAPINotifyPushOn) -> Void,
                              errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.notifyPushOn(fcmToken: fcmToken)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { responseAPIResult in
                                                guard let result = (responseAPIResult as! ResponseAPINotifyPushOnResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPINotifyPushOnResult).error
                                                    Logger.log(message: "\nAPI `push.notifyOn` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `push.notifyOn` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { errorAPI in
                                                Logger.log(message: "\nAPI `push.notifyOn` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }
    
    // API `push.notifyOff`
    public func pushNotifyOff(responseHandling:     @escaping (ResponseAPINotifyPushOff) -> Void,
                              errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            return errorHandling(ErrorAPI.invalidData(message: "FCM token key don't found".localized()))
        }
        
        let methodAPIType = MethodAPIType.notifyPushOff(fcmToken: fcmToken)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { responseAPIResult in
                                                guard let result = (responseAPIResult as! ResponseAPINotifyPushOffResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPINotifyPushOffResult).error
                                                    Logger.log(message: "\nAPI `push.notifyOff` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `push.notifyOff` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { errorAPI in
                                                Logger.log(message: "\nAPI `push.notifyOff` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                                                errorHandling(errorAPI)
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
    
    // API `options.get`
    public func getOptions(responseHandling:    @escaping (ResponseAPIGetOptions) -> Void,
                           errorHandling:       @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.getOptions
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPIGetOptionsResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPIGetOptionsResult).error
                                                    Logger.log(message: "\nAPI `options.get` response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI `options.get` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI `options.get` response error: \n\(errorAPI.caseInfo.message)\n", event: .error)
                                                errorHandling(errorAPI)
        })
    }
    
    // API basic `options.set`
    public func setBasicOptions(language:           String,
                                nsfwContent:        NsfwContentMode,
                                responseHandling:   @escaping (ResponseAPISetOptionsBasic) -> Void,
                                errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard Config.currentUser?.id != nil else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue, language: language)
        
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
    
    // API notify/push `options.set`
    public func set(options:            RequestParameterAPI.NoticeOptions,
                    type:               NoticeType,
                    responseHandling:   @escaping (ResponseAPISetOptionsNotice) -> Void,
                    errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard (Config.currentUser?.id != nil) else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }
        
        let methodAPIType = MethodAPIType.setNotice(options: options, type: type)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                guard let result = (responseAPIResult as! ResponseAPISetOptionsNoticeResult).result else {
                                                    let responseAPIError = (responseAPIResult as! ResponseAPISetOptionsNoticeResult).error
                                                    Logger.log(message: "\nAPI \(type.hashValue == 0 ? "push" : "notify") \'options.set\' response mapping error: \n\(responseAPIError!.message)\n", event: .error)
                                                    return errorHandling(ErrorAPI.jsonParsingFailure(message: "\(responseAPIError!.message)"))
                                                }
                                                
                                                Logger.log(message: "\nAPI \(type.hashValue == 0 ? "push" : "notify") `options.set` response result: \n\(responseAPIResult)\n", event: .debug)
                                                responseHandling(result)
        },
                                             onError:           { (errorAPI) in
                                                Logger.log(message: "\nAPI \(type.hashValue == 0 ? "push" : "notify") `options.set` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
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

    /// Action `updatemeta`
    public func update(userProfile:         [String: String?],
                       appProfileType:      AppProfileType = .cyber,
                       responseHandling:    @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       errorHandling:       @escaping (Error) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard let userID = Config.currentUser?.id else { return errorHandling(ErrorAPI.invalidData(message: "Unauthorized")) }
        
        let userProfileAccountmetaArgs = EOSTransaction.UserProfileAccountmetaArgs(json: userProfile)
        
        let userProfileMetaArgs = EOSTransaction.UserProfileUpdatemetaArgs(accountValue:    userID,
                                                                           metaValue:       userProfileAccountmetaArgs)
        
//        let userProfileAccountmetaArgs: Encodable = appProfileType == .cyber ?  EOSTransaction.CyberUserProfileAccountmetaArgs(json: userProfile) :
//                                                                                EOSTransaction.GolosUserProfileAccountmetaArgs(json: userProfile)
//
//        let userProfileMetaArgs = EOSTransaction.CyberUserProfileAccountmetaArgs(json: userProfile)
        
        EOSManager.update(userProfileMetaArgs:  userProfileMetaArgs,
                          responseResult:       { result in
                            Logger.log(message: "\nAction `updatemeta` response result: \n\(result)\n", event: .debug)
                            responseHandling(result)
        },
                          responseError:        { errorAPI in
                            Logger.log(message: "\nAction `updatemeta` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                            errorHandling(errorAPI)
        })
    }

    
    //  MARK: - Contract `gls.publish`
    /// Actions `upvote`, `downvote`, `unvote`
    public func message(voteActionType:     VoteActionType,
                        author:             String,
                        permlink:           String,
                        weight:             Int16 = 0,
                        responseHandling:   @escaping (ChainResponse<TransactionCommitted>) -> Void,
                        errorHandling:      @escaping (ErrorAPI) -> Void) {
        // Offline mode
        guard Config.isNetworkAvailable else { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        EOSManager.message(voteActionType:  voteActionType,
                           author:          author,
                           permlink:        permlink,
                           weight:          voteActionType == .unvote ? 0 : 1,
                           responseResult:  { response in
                            Logger.log(message: "\nAction `\(voteActionType.hashValue)` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                           responseError:   { error in
                            Logger.log(message: "\nAction `\(voteActionType.hashValue)` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `createmssg`
    public func create(message:             String,
                       headline:            String? = "",
                       parentPermlink:      String? = nil,
                       tags:                [String]?,
                       metaData:            String,
                       responseHandling:    @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       errorHandling:       @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        EOSManager.create(message:          message,
                          headline:         headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
                          tags:             arrayTags,
                          jsonMetaData:     metaData,
                          responseResult:   { (responseAPIResult) in
                            Logger.log(message: "\nAction `createmssg` response result: \n\(responseAPIResult)\n", event: .debug)
                            responseHandling(responseAPIResult)
        },
                          responseError:    { (errorAPI) in
                            Logger.log(message: "\nAction `createmssg` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: errorAPI.localizedDescription))
        })
    }
    
    /// Action `updatemssg`
    public func updateMessage(author:               String?,
                              permlink:             String,
                              message:              String,
                              parentPermlink:       String?,
                              responseHandling:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                              errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(authorValue:           author ?? Config.currentUser?.id ?? "Cyberway",
                                                                 messagePermlink:       permlink,
                                                                 parentPermlink:       parentPermlink,
                                                                 bodymssgValue:         message)
        
        EOSManager.update(messageArgs:      messageUpdateArgs,
                          responseResult:   { response in
                            Logger.log(message: "\nAction `updatemssg` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                          responseError:    { error in
                            Logger.log(message: "\nAction `updatemssg` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `deletemssg`
    public func deleteMessage(author:               String,
                              permlink:             String,
                              responseHandling:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                              errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue: author, messagePermlink: permlink)
        
        EOSManager.delete(messageArgs:      messageDeleteArgs,
                          responseResult:   { response in
                            Logger.log(message: "\nAction `deletemssg` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                          responseError:    { error in
                            Logger.log(message: "\nAction `deletemssg` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `reblog`
    public func reblogMessage(author:               String,
                              rebloger:             String,
                              permlink:             String,
                              headermssg:           String,
                              bodymssg:             String,
                              responseHandling:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                              errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        EOSManager.message(reblogArgs:              reblogArgs,
                           responseResult:          { response in
                            Logger.log(message: "\nAction `reblog` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                          responseError:            { errorAPI in
                            Logger.log(message: "\nAction `reblog` response error: \n\(errorAPI.localizedDescription)\n", event: .error)
                            errorHandling(errorAPI)
        })
    }
    
    
    // MARK: - Contract `gls.ctrl`
    /// Action `regwitness` (1)
    public func reg(witness:                String,
                    url:                    String,
                    responseHandling:       @escaping (ChainResponse<TransactionCommitted>) -> Void,
                    errorHandling:          @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let regwitnessArgs = EOSTransaction.RegwitnessArgs(witnessValue: witness, urlValue: url)
        
        EOSManager.reg(witnessArgs:     regwitnessArgs,
                       responseResult:  { response in
                        Logger.log(message: "\nAction `regwitness` response result: \n\(response)\n", event: .debug)
                        responseHandling(response)
        },
                       responseError:   { error in
                        Logger.log(message: "\nAction `regwitness` response error: \n\(error.localizedDescription)\n", event: .error)
                        errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `votewitness` (2)
    public func vote(witness:               String,
                     voter:                 String,
                     responseHandling:      @escaping (ChainResponse<TransactionCommitted>) -> Void,
                     errorHandling:         @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let votewitnessArgs = EOSTransaction.VotewitnessArgs(voterValue: voter, witnessValue: witness)
        
        EOSManager.vote(witnessArgs:        votewitnessArgs,
                        responseResult:  { response in
                            Logger.log(message: "\nAction `votewitness` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                        responseError:   { error in
                            Logger.log(message: "\nAction `votewitness` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `unvotewitn` (3)
    public func unvote(witness:             String,
                       voter:               String,
                       responseHandling:    @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       errorHandling:       @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let unvotewitnessArgs = EOSTransaction.UnvotewitnessArgs(voterValue: voter, witnessValue: witness)
        
        EOSManager.unvote(witnessArgs:      unvotewitnessArgs,
                          responseResult:  { response in
                            Logger.log(message: "\nAction `unvotewitn` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                          responseError:   { error in
                            Logger.log(message: "\nAction `unvotewitn` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
    
    /// Action `unregwitness` (4)
    public func unreg(witness:              String,
                      responseHandling:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                      errorHandling:        @escaping (ErrorAPI) -> Void) {
        // Offline mode
        if (!Config.isNetworkAvailable) { return errorHandling(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let unregwitnessArgs = EOSTransaction.UnregwitnessArgs(witnessValue: witness)
        
        EOSManager.unreg(witnessArgs:       unregwitnessArgs,
                         responseResult:  { response in
                            Logger.log(message: "\nAction `unregwitness` response result: \n\(response)\n", event: .debug)
                            responseHandling(response)
        },
                         responseError:   { error in
                            Logger.log(message: "\nAction `unregwitness` response error: \n\(error.localizedDescription)\n", event: .error)
                            errorHandling(ErrorAPI.responseUnsuccessful(message: error.localizedDescription))
        })
    }
}

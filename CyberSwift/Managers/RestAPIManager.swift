//  RestAPIManager.swift
//  CyberSwift
//
//  Created by msm72 on 12.07.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import eosswift
import Foundation

public typealias UserKeys = (type: String, privateKey: String, publicKey: String)

public enum UserKeyType: String {
    case memo       =   "memo"
    case owner      =   "owner"
    case active     =   "active"
    case posting    =   "posting"
}

public class RestAPIManager {
    // MARK: - Properties
    public static let instance = RestAPIManager()
    
    
    // MARK: - Class Initialization
    private init() {}
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }
    
    
    // MARK: - Class Functions
    private func generate(keyTypes: [UserKeyType], nickName: String, password: String) -> [UserKeys] {
        var userKeys: [UserKeys] = [UserKeys]()
        
        for keyType in keyTypes {
            let seed                =   nickName + keyType.rawValue + password
            let brainKey            =   seed.removeWhitespaceCharacters()
            let brainKeyBytes       =   brainKey.bytes
            
            var brainKeyBytesSha256 =   brainKeyBytes.sha256()
            brainKeyBytesSha256.insert(0x80, at: 0)
            
            let checksumSha256Bytes =   brainKeyBytesSha256.generateChecksumSha256()
            brainKeyBytesSha256     +=  checksumSha256Bytes
            
            if let privateKey = PrivateKey(brainKeyBytesSha256.base58EncodedString) {
                let publicKey = privateKey.createPublic(prefix: PublicKey.AddressPrefix.mainNet)
                userKeys.append((type: keyType.rawValue, privateKey: privateKey.description, publicKey: publicKey.description))
            }
        }
        
        return userKeys
    }
    
    
    // MARK: - FACADE-SERVICE
    // API `auth.authorize`
    public func authorize(userNickName: String, userActiveKey: String, completion: @escaping (ResponseAPIAuthAuthorize?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.authorize(nickName: userNickName, activeKey: userActiveKey)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIAuthAuthorizeResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'auth.authorize\' have error: \((responseAPIResult as! ResponseAPIAuthAuthorizeResult).error!.message)"))
                                                        return
                                                    }
                                                    
                                                    DispatchQueue.main.async(execute: {
                                                        UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
                                                        
                                                        // Save in Keychain
                                                        _ = KeychainManager.save(data: [Config.currentUserNickNameKey: userNickName], userNickName: Config.currentUserNickNameKey)
                                                        _ = KeychainManager.save(data: [Config.currentUserPublicActiveKey: userActiveKey], userNickName: Config.currentUserPublicActiveKey)
                                                        
                                                        completion(result, nil)
                                                    })
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
    
    // API `auth.generateSecret`
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
    
    // API `content.getProfile`
    public func getProfile(nickName: String, type: ProfileType = .cyber, completion: @escaping (ResponseAPIContentGetProfile?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getProfile(nickName: nickName, type: type)
            
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
    
    // API `content.getFeed`
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
    
    // API `content.getPost`
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
    
    // API `content.getComments` by user
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
    
    // API `content.getComments` by post
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
    
    // API `push.historyFresh`
    public func getPushHistoryFresh(nickName: String = Config.currentUser.nickName ?? "Cyberway", completion: @escaping (ResponseAPIPushHistoryFresh?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getPushHistoryFresh(profile: String(format: "%@%@", nickName, Config.currentDeviceType))
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIPushHistoryFreshResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API \'push.historyFresh\' have error: \((responseAPIResult as! ResponseAPIPushHistoryFreshResult).error!.message)"))
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
    
    // API `onlineNotify.history`
    public func getOnlineNotifyHistory(fromId: String? = nil, paginationLimit: Int8 = Config.paginationLimit, markAsViewed: Bool = false, freshOnly: Bool = false, completion: @escaping (ResponseAPIOnlineNotifyHistory?, ErrorAPI?) -> Void) {
        if (!Config.isNetworkAvailable) {return completion(nil, ErrorAPI.disableInternetConnection(message: nil))}
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistory(fromId: fromId, paginationLimit: paginationLimit, markAsViewed: markAsViewed, freshOnly: freshOnly)
        
        Broadcast.instance.executeGETRequest(byContentAPIType: methodAPIType, onResult: { (responseAPIResult) in
            Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
            guard let result = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryResult).result else {
                completion(nil, ErrorAPI.requestFailed(message: "API \'onlineNotify.history\' have error: \((responseAPIResult as! ResponseAPIOnlineNotifyHistoryResult).error!.message)"))
                return
            }
            completion(result, nil)
        }) { (errorAPI) in
            Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
            
            completion(nil, errorAPI)
        }
    }
    
    // API `onlineNotify.historyFresh`
    public func getOnlineNotifyHistoryFresh(completion: @escaping (ResponseAPIOnlineNotifyHistoryFresh?, ErrorAPI?) -> Void) {
        if (!Config.isNetworkAvailable) {return completion(nil, ErrorAPI.disableInternetConnection(message: nil))}
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistoryFresh
        
        Broadcast.instance.executeGETRequest(byContentAPIType: methodAPIType, onResult: { (responseAPIResult) in
            Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
            guard let result = (responseAPIResult as! ResponseAPIOnlineNotifyHistoryFreshResult).result else {
                completion(nil, ErrorAPI.requestFailed(message: "API \'onlineNotify.historyFresh\' have error: \((responseAPIResult as! ResponseAPIOnlineNotifyHistoryFreshResult).error!.message)"))
                return
            }
            completion(result, nil)
        }) { (errorAPI) in
            Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
            
            completion(nil, errorAPI)
        }
    }
    
    // API `notify.markAllAsViewed`
    public func notifyMarkAllAsViewed(completion: @escaping (ResponseAPINotifyMarkAllAsViewed?, ErrorAPI?) -> Void) {
        if (!Config.isNetworkAvailable) {return completion(nil, ErrorAPI.disableInternetConnection(message: nil))}
        
        let methodAPIType = MethodAPIType.notifyMarkAllAsViewed
        
        Broadcast.instance.executeGETRequest(byContentAPIType: methodAPIType, onResult: { (responseAPIResult) in
            Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
            guard let result = (responseAPIResult as! ResponseAPINotifyMarkAllAsViewedResult).result else {
                completion(nil, ErrorAPI.requestFailed(message: "API \'onlineNotify.historyFresh\' have error: \((responseAPIResult as! ResponseAPINotifyMarkAllAsViewedResult).error!.message)"))
                return
            }
            completion(result, nil)
        }) { (errorAPI) in
            Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
            
            completion(nil, errorAPI)
        }
    }

    // API `options.get`
    public func getOptions(completion: @escaping (ResponseAPIGetOptions?, ErrorAPI?) -> Void) {
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard Config.currentUser.nickName != nil else {
            return completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
        
        let methodAPIType = MethodAPIType.getOptions
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                
                                                guard let result = (responseAPIResult as! ResponseAPIGetOptionsResult).result else {
                                                    completion(nil, ErrorAPI.requestFailed(message: "API \'options.get\' have error: \((responseAPIResult as! ResponseAPIGetOptionsResult).error!.message)"))
                                                    return
                                                }
                                                
                                                completion(result, nil)
        }) { (errorAPI) in
            Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
            
            completion(nil, errorAPI)
        }
    }

    // API basic `options.set`
    public func setBasicOptions(language: String, nsfwContent: NsfwContentMode, completion: @escaping (ResponseAPISetOptionsBasic?, ErrorAPI?) -> Void) {
        if (!Config.isNetworkAvailable) { return completion(nil, ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard (Config.currentUser.nickName != nil) else {
            return completion(nil, ErrorAPI.disableInternetConnection(message: nil))
        }
        
        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue, language: language)
        
        Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                             onResult:          { (responseAPIResult) in
                                                Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                
                                                guard let result = (responseAPIResult as! ResponseAPISetOptionsBasicResult).result else {
                                                    completion(nil, ErrorAPI.requestFailed(message: "API basic \'options.set\' have error: \((responseAPIResult as! ResponseAPISetOptionsBasicResult).error!.message)"))
                                                    return
                                                }
                                                
                                                completion(result, nil)
        }) { (errorAPI) in
            Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
            
            completion(nil, errorAPI)
        }
    }

    
    // MARK: - REGISTRATION-SERVICE
    // API `registration.getState`
    public func getState(nickName: String? = Config.currentUser.nickName, phone: String?, completion: @escaping (ResponseAPIRegistrationGetState?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.getState(nickName: nickName, phone: phone)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIRegistrationGetStateResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'registration.getState\' have error: \((responseAPIResult as! ResponseAPIRegistrationGetStateResult).error!.message)"))
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

    // API `registration.firstStep`
    public func firstStep(phone: String, isDebugMode: Bool = true, completion: @escaping (ResponseAPIRegistrationFirstStep?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.firstStep(phone: phone, isDebugMode: isDebugMode)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIRegistrationFirstStepResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'registration.firstStep\' have error: \((responseAPIResult as! ResponseAPIRegistrationFirstStepResult).error!.message)"))
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

    // API `registration.verify`
    public func verify(phone: String, code: String, isDebugMode: Bool = true, completion: @escaping (ResponseAPIRegistrationVerify?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.verify(phone: phone, code: code, isDebugMode: isDebugMode)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIRegistrationVerifyResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'registration.verify\' have error: \((responseAPIResult as! ResponseAPIRegistrationVerifyResult).error!.message)"))
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

    // API `registration.setUsername`
    public func setUser(name: String, phone: String, isDebugMode: Bool = true, completion: @escaping (ResponseAPIRegistrationSetUsername?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.setUser(name: name, phone: phone, isDebugMode: isDebugMode)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIRegistrationSetUsernameResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'registration.setUsername\' have error: \((responseAPIResult as! ResponseAPIRegistrationSetUsernameResult).error!.message)"))
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

    // API `registration.resendSmsCode`
    public func resendSmsCode(phone: String, isDebugMode: Bool = true, completion: @escaping (ResponseAPIResendSmsCode?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let methodAPIType = MethodAPIType.resendSmsCode(phone: phone, isDebugMode: isDebugMode)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard let result = (responseAPIResult as! ResponseAPIResendSmsCodeResult).result else {
                                                        completion(nil, ErrorAPI.requestFailed(message: "API post \'registration.resendSmsCode\' have error: \((responseAPIResult as! ResponseAPIResendSmsCodeResult).error!.message)"))
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

    // API `registration.toBlockChain`
    public func toBlockChain(nickName: String, completion: @escaping (Bool, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let userkeys = RestAPIManager.instance.generate(keyTypes:   [.owner, .active, .posting, .memo],
                                                            nickName:   nickName,
                                                            password:   String.randomString(length: 12))

            let methodAPIType = MethodAPIType.toBlockChain(nickName: nickName, keys: userkeys)
            
            Broadcast.instance.executeGETRequest(byContentAPIType:  methodAPIType,
                                                 onResult:          { responseAPIResult in
                                                    Logger.log(message: "\nresponse API Result = \(responseAPIResult)\n", event: .debug)
                                                    
                                                    guard (responseAPIResult as! ResponseAPIRegistrationToBlockChainResult).result != nil else {
                                                        completion(false, ErrorAPI.requestFailed(message: "API post \'registration.toBlockChain\' have error: \((responseAPIResult as! ResponseAPIRegistrationToBlockChainResult).error!.message)"))
                                                        return
                                                    }
                                                    
                                                    // Save in Keychain
                                                    let result: Bool = KeychainManager.save(keys: userkeys, nickName: nickName)
                                                    completion(result, nil)
            },
                                                 onError: { errorAPI in
                                                    Logger.log(message: "nresponse API Error = \(errorAPI.caseInfo.message)\n", event: .error)
                                                    
                                                    completion(false, errorAPI)
            })
        }
            
        // Offline mode
        else {
            completion(false, ErrorAPI.disableInternetConnection(message: nil))
        }
    }

    
    //  MARK: - Contract `gls.publish`
    /// Actions `upvote`, `downvote`, `unvote`
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
    
    /// Action `createmssg`
    public func create(message: String, headline: String? = "", parentData: ParentData? = nil, tags: [String]?, metaData: String?, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
            
            EOSManager.create(message:         message,
                              headline:        headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
                              tags:            arrayTags,
                              jsonMetaData:    metaData,
                              completion:      { (response, error) in
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
    
    /// Action `updatemssg`
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
    
    /// Action `deletemssg`
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
    
    /// Action `reblog`
    public func reblog(author: String, permlink: String, refBlockNum: UInt64, rebloger: String, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                       permlinkValue:       permlink,
                                                       refBlockNumValue:    refBlockNum,
                                                       reblogerValue:       rebloger)
            
            EOSManager.reblog(args:         reblogArgs,
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
    

    // MARK: - Contract `gls.ctrl`
    /// Action `regwitness` (1)
    public func reg(witness: String, url: String, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let regwitnessArgs = EOSTransaction.RegwitnessArgs(witnessValue: witness, urlValue: url)
            
            EOSManager.reg(witnessArgs:     regwitnessArgs,
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
    
    /// Action `votewitness` (2)
    public func vote(witness: String, voter: String, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let votewitnessArgs = EOSTransaction.VotewitnessArgs(voterValue: voter, witnessValue: witness)
            
            EOSManager.vote(witnessArgs:    votewitnessArgs,
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
    
    /// Action `unvotewitn` (3)
    public func unvote(witness: String, voter: String, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let unvotewitnessArgs = EOSTransaction.UnvotewitnessArgs(voterValue: voter, witnessValue: witness)
            
            EOSManager.unvote(witnessArgs:  unvotewitnessArgs,
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
    
    /// Action `unregwitness` (4)
    public func unreg(witness: String, completion: @escaping (ChainResponse<TransactionCommitted>?, ErrorAPI?) -> Void) {
        if Config.isNetworkAvailable {
            let unregwitnessArgs = EOSTransaction.UnregwitnessArgs(witnessValue: witness)
            
            EOSManager.unreg(witnessArgs:     unregwitnessArgs,
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
}

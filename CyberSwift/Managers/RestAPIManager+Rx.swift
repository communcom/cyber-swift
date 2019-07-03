//
//  RestAPIManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension RestAPIManager: ReactiveCompatible {}

extension Reactive where Base: RestAPIManager {
    //  MARK: - Registration
    /// Get registration state
    public func getState() -> Single<ResponseAPIRegistrationGetState> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let id = Config.currentUser?.id,
            let phone = Config.currentUser?.phoneNumber else {
                return .error(ErrorAPI.unauthorized)
        }
        
        let methodAPIType = MethodAPIType.getState(id: id, phone: phone)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.getState")
            .map { result in
                guard let result = (result as? ResponseAPIRegistrationGetStateResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                return result
            }
    }
    
    /// First step of registration
    public func firstStep(phone: String) -> Single<ResponseAPIRegistrationFirstStep> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.firstStep(phone: phone, isDebugMode: base.isDebugMode)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.firstStep")
            .map {result in
                guard let result = (result as? ResponseAPIRegistrationFirstStepResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                try KeychainManager.save(data: [
                    Config.registrationStepKey: "verify",
                    Config.registrationUserPhoneKey: phone,
                    Config.registrationSmsCodeKey: result.code,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
            }
    }
    
    /// Verify code
    public func verify(code: UInt64) -> Single<ResponseAPIRegistrationVerify> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let phone = Config.currentUser?.phoneNumber else {
            return .error(ErrorAPI.requestFailed(message: "Phone and smsCode missing"))
        }
        
        let methodAPIType = MethodAPIType.verify(phone: phone, code: code)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.verify")
            .map {result in
                guard let result = (result as? ResponseAPIRegistrationVerifyResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                try KeychainManager.save(data: [
                    Config.registrationStepKey: "setUsername",
                    Config.registrationSmsCodeKey: code
                ])
                
                return result
            }
    }
    
    
    /// Resend sms code
    public func resendSmsCode() -> Single<ResponseAPIResendSmsCode> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let phone = Config.currentUser?.phoneNumber else {
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.resendSmsCode(phone: phone, isDebugMode: base.isDebugMode)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.resendSmsCode")
            .map {result in
                guard let result = (result as? ResponseAPIResendSmsCodeResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                try KeychainManager.save(data: [
                    Config.registrationStepKey: "verify",
                    Config.registrationSmsCodeKey: result.code,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
            }
    }
    
    /// set userId
    public func setUser(id: String) -> Single<ResponseAPIRegistrationSetUsername> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let phone = Config.currentUser?.phoneNumber else {
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.setUser(id: id, phone: phone)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.setUsername")
            .map {result in
                guard let result = (result as? ResponseAPIRegistrationSetUsernameResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                try KeychainManager.save(data: [
                    Config.registrationStepKey: "toBlockChain",
                    Config.registrationUserIDKey: id
                ])
                
                return result
            }
    }
    
    /// Save user to blockchain
    public func toBlockChain() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let id = Config.currentUser?.id else {
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let userkeys = base.generateKeys(userID: id, password: String.randomString(length: 12))
        
        let methodAPIType = MethodAPIType.toBlockChain(userID: id, keys: userkeys)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.toBlockChain")
            .map {result -> ResponseAPIRegistrationToBlockChain in
                guard let result = (result as? ResponseAPIRegistrationToBlockChainResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                #warning("remove step later")
                try KeychainManager.save(data: [
                    Config.registrationStepKey: "firstStep",
                    Config.registrationUserNameKey: result.username,
                    Config.registrationUserIDKey: result.userId,
                    Config.currentUserPublicOwnerKey: userkeys["owner"]!.publicKey,
                    Config.currentUserPrivateOwnerKey: userkeys["owner"]!.privateKey,
                    Config.currentUserPublicActiveKey: userkeys["active"]!.publicKey,
                    Config.currentUserPrivateActiveKey: userkeys["active"]!.privateKey,
                    Config.currentUserPublicPostingKey: userkeys["posting"]!.publicKey,
                    Config.currentUserPrivatePostingKey: userkeys["posting"]!.privateKey,
                    Config.currentUserPublickMemoKey: userkeys["memo"]!.publicKey,
                    Config.currentUserPrivateMemoKey: userkeys["memo"]!.privateKey
                ])
            
                return result
            }
            .flatMapToCompletable()
            .do(onCompleted: {
                PDFManager.createPDFFile()
                // Auth new account
                DispatchQueue.main.async {
                    RestAPIManager.instance.authorize(
                        userID: Config.currentUser!.id!,
                        userActiveKey: Config.currentUser!.activeKey!,
                        responseHandling: { response in
                            responseHandling(true)
                    },
                        errorHandling: { error in
                            errorHandling(error.toErrorAPI())
                    })
                }
            })
    }
    
    //  MARK: - Contract `gls.publish`
    public func vote(voteType:       VoteActionType,
                     author:         String,
                     permlink:       String,
                     weight:         Int16 = 0) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        return EOSManager.rx.vote(voteType:     voteType,
                                  author:       author,
                                  permlink:     permlink,
                                  weight:       voteType == .unvote ? 0 : 1)
    }
    
    public func create(message:             String,
                       headline:            String? = nil,
                       parentPermlink:      String? = nil,
                       tags:                [String]?,
                       metaData:            String) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        let messageCreateArgs = EOSTransaction.MessageCreateArgs(authorValue:        userID,
                                                                 parentPermlink:     parentPermlink,
                                                                 headermssgValue:    headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
                                                                 bodymssgValue:      message,
                                                                 tagsValues:         arrayTags,
                                                                 jsonmetadataValue:  metaData)
        
        return EOSManager.rx.create(messageCreateArgs: messageCreateArgs)
    }
    
    public func deleteMessage(author: String, permlink: String) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue: author, messagePermlink: permlink)
        return EOSManager.rx.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(author:       String?,
                              permlink:     String,
                              message:      String,
                              parentPermlink:   String?) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(authorValue:           author ?? Config.currentUser?.id ?? "Cyberway",
                                                                 messagePermlink:       permlink,
                                                                 parentPermlink:        parentPermlink,
                                                                 bodymssgValue:         message)
        return EOSManager.rx.update(messageArgs: messageUpdateArgs)
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       headermssg:          String,
                       bodymssg:            String) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        return EOSManager.rx.reblog(args: reblogArgs)
    }
    
    // MARK: - Contract `gls.social`
    public func update(userProfile: [String: String]) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        guard Config.isNetworkAvailable else { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let userProfileAccountmetaArgs = EOSTransaction.UserProfileAccountmetaArgs(json: userProfile)
        
        let userProfileMetaArgs = EOSTransaction.UserProfileUpdatemetaArgs(accountValue:    userID,
                                                                           metaValue:       userProfileAccountmetaArgs)
        
        return EOSManager.rx.update(userProfileMetaArgs: userProfileMetaArgs)
    }
    
    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        guard Config.isNetworkAvailable else { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let pinArgs = EOSTransaction.UserProfilePinArgs(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.rx.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }
}

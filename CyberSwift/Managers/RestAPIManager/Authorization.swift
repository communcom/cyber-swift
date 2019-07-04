//
//  Registration+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift

extension Reactive where Base: RestAPIManager {
    // MARK: - Public function
    /// Get registration state
    public func getState() -> Single<ResponseAPIRegistrationGetState> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let id = Config.currentUser?.id,
            let phone = Config.currentUser?.phoneNumber else {
                Logger.log(message: "userId or phoneNumber missing for user: \(String(describing: Config.currentUser))", event: .error)
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
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
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
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
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
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
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
            Logger.log(message: "userId missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId missing"))
        }
        
        let userkeys = generateKeys(userID: id, password: String.randomString(length: 12))
        
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
                // Save pdf
                PDFManager.createPDFFile()
                
                // Save in iCloud keyvalue
                iCloudManager.saveUser()
            })
    }
    
    /// Authorize registration user
    public func authorize() -> Single<ResponseAPIAuthAuthorize> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let userId = Config.currentUser?.id,
            let activeKey = Config.currentUser?.activeKey
        else {
            Logger.log(message: "userId or activeKey missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId or activeKey missing"))
        }
        
        let methodAPIType = MethodAPIType.authorize(userID: userId, activeKey: activeKey)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "auth.authorize")
            .map {result in
                guard let result = (result as? ResponseAPIAuthAuthorizeResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                try KeychainManager.save(data: [
                    Config.currentUserNameKey: result.displayName
                ])
                
                return result
            }
            .do(onSuccess: {result in
                // Save to UserDefault
                UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
                
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
            })
    }
    
    // MARK: - Private functions
    private func generateKeys(userID: String, password: String) -> [String: UserKeys] {
        var userKeys = [String: UserKeys]()
        
        // type
        let types = ["owner", "active", "posting", "memo"]
        
        for keyType in types {
            let seed                =   userID + keyType + password
            let brainKey            =   seed.removeWhitespaceCharacters()
            let brainKeyBytes       =   brainKey.bytes
            
            var brainKeyBytesSha256 =   brainKeyBytes.sha256()
            brainKeyBytesSha256.insert(0x80, at: 0)
            
            let checksumSha256Bytes =   brainKeyBytesSha256.generateChecksumSha256()
            brainKeyBytesSha256     +=  checksumSha256Bytes
            
            if let privateKey = PrivateKey(brainKeyBytesSha256.base58EncodedString) {
                let publicKey = privateKey.createPublic(prefix: PublicKey.AddressPrefix.mainNet)
                userKeys[keyType] = UserKeys(privateKey: privateKey.description, publicKey: publicKey.description)
            }
        }
        
        return userKeys
    }
}

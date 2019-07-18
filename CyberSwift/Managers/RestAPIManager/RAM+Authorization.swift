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
    public func getState(userId: String? = Config.currentUser?.id, phone: String? = Config.currentUser?.phoneNumber) -> Single<ResponseAPIRegistrationGetState> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.getState(id: userId, phone: userId == nil ? phone: nil)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "registration.getState")
            .map { result in
                guard let result = (result as? ResponseAPIRegistrationGetStateResult)?.result else {
                    throw ErrorAPI.unknown
                }
                
                // save state
                var dataToSave = [String: Any]()
                if let id = userId ?? result.user {
                    dataToSave[Config.currentUserIDKey] = id
                } else if let phone = phone {
                    dataToSave[Config.registrationUserPhoneKey] = phone
                }
                dataToSave[Config.registrationStepKey] = result.currentState
                
                try KeychainManager.save(data: dataToSave)
                
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
                    Config.registrationStepKey: CurrentUserRegistrationStep.verify.rawValue,
                    Config.registrationUserPhoneKey: phone,
                    Config.registrationSmsCodeKey: result.code,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
        }
    }
    
    /// Verify code
    public func verify() -> Single<ResponseAPIRegistrationVerify> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let phone = Config.currentUser?.phoneNumber,
            let code = Config.currentUser?.smsCode
        else {
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
                    Config.registrationStepKey: CurrentUserRegistrationStep.setUserName.rawValue,
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
                    Config.registrationStepKey: CurrentUserRegistrationStep.verify.rawValue,
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
                    Config.registrationStepKey: CurrentUserRegistrationStep.toBlockChain.rawValue,
                    Config.currentUserIDKey: id
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
                
                try KeychainManager.save(data: [
                    Config.registrationStepKey: CurrentUserRegistrationStep.registered.rawValue,
                    Config.currentUserNameKey: result.username,
                    Config.currentUserIDKey: result.userId,
                    Config.currentUserPublicOwnerKey: userkeys["owner"]!.publicKey!,
                    Config.currentUserPrivateOwnerKey: userkeys["owner"]!.privateKey!,
                    Config.currentUserPublicActiveKey: userkeys["active"]!.publicKey!,
                    Config.currentUserPrivateActiveKey: userkeys["active"]!.privateKey!,
                    Config.currentUserPublicPostingKey: userkeys["posting"]!.publicKey!,
                    Config.currentUserPrivatePostingKey: userkeys["posting"]!.privateKey!,
                    Config.currentUserPublickMemoKey: userkeys["memo"]!.publicKey!,
                    Config.currentUserPrivateMemoKey: userkeys["memo"]!.privateKey!
                ])
                
                return result
            }
//            .flatMap {_ in
//                return self.authorize()
//            }
            .flatMapToCompletable()
    }
    
    /// Set passcode
    public func setPasscode(_ passcode: String) throws {
        guard passcode.count == 4, Int(passcode) != nil else {return}
        try KeychainManager.save(data: [
            Config.settingStepKey: CurrentUserSettingStep.setFaceId.rawValue,
            Config.currentUserPasscodeKey: passcode
        ])
    }
    
    /// backupIcloud
    public func backUpICloud() throws {
        iCloudManager.saveUser()
        try KeychainManager.save(data: [
            Config.settingStepKey: CurrentUserSettingStep.setAvatar.rawValue
        ])
    }
    
    /// Authorize registration user or login
    public func authorize(login: String? = nil, key: String? = nil) -> Single<ResponseAPIAuthAuthorize> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let userId = login ?? Config.currentUser?.id,
            let activeKey = key ?? Config.currentUser?.activeKey
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
                
                var dataToSave: [String: Any] = [
                    Config.currentUserNameKey: result.displayName,
                    Config.registrationStepKey: CurrentUserRegistrationStep.registered.rawValue,
                    Config.settingStepKey: CurrentUserSettingStep.completed.rawValue
                ]
                
                if let login = login {dataToSave[Config.currentUserIDKey] = login}
                if let key = key {dataToSave[Config.currentUserPrivateActiveKey] = key}
                
                try KeychainManager.save(data: dataToSave)
                
                return result
            }
            .catchError({ (error) -> Single<ResponseAPIAuthAuthorize> in
                if let error = error as? ErrorAPI {
                    let message = error.caseInfo.message
                    
                    if message == "There is no secret stored for this channelId. Probably, client's already authorized" ||
                        message == "Secret verification failed - access denied"{
                        // retrieve secret
                        return self.generateSecret()
                            .andThen(self.authorize(login: login, key: key))
                    }
                }
                throw error
            })
            .do(onError: {error in
                if let error = error as? ErrorAPI {
                    switch error.caseInfo.message {
                    case "Secret verification failed - access denied",
                         "Public key verification failed - access denied",
                         "Sign is not a valid signature",
                         "Cannot get such account from BC":
                        try? CurrentUser.logout()
                    default:
                        break
                    }
                }
            })
    }
    
    /// Turn on push notification
    public func pushNotifyOn() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let token = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            return .error(ErrorAPI.requestFailed(message: "Token not found"))
        }
        
        let methodAPIType = MethodAPIType.notifyPushOn(fcmToken: token, appProfileType: AppProfileType.golos)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "push.notifyOn")
            .flatMapToCompletable()
    }
    
    /// Turn off push notification
    public func pushNotifyOff() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.notifyPushOff(appProfileType: AppProfileType.golos)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "push.notifyOff")
            .flatMapToCompletable()
    }
    
    /// Generate secret
    private func generateSecret() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.generateSecret
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "auth.generateSecret")
            .flatMapCompletable {result in
                guard let result = (result as? ResponseAPIAuthGenerateSecretResult)?.result else {
                    throw ErrorAPI.unknown
                }
                Config.webSocketSecretKey = result.secret
                return .empty()
            }
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

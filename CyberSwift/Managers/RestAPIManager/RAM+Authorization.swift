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
        
        let methodAPIType = MethodAPIType.getState(id: userId, phone: userId == nil ? phone : nil)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationGetState>)
            .map { result in
                // save state
                var dataToSave = [String: Any]()
                if let id = userId ?? result.user {
                    dataToSave[Config.currentUserIDKey] = id
                } else if let phone = phone {
                    dataToSave[Config.registrationUserPhoneKey] = phone
                }
                dataToSave[Config.registrationStepKey] = result.currentState
                
                try KeychainManager.save(dataToSave)
                
                return result
        }
    }
    
    /// First step of registration
    public func firstStep(phone: String) -> Single<ResponseAPIRegistrationFirstStep> {
        
        let methodAPIType = MethodAPIType.firstStep(phone: phone.trimSpaces(), isDebugMode: base.isDebugMode)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationFirstStep>)
            .map {result in
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.verify.rawValue,
                    Config.registrationUserPhoneKey: phone.trimSpaces(),
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
        }
    }
    
    /// Verify code
    public func verify(code: UInt64) -> Single<ResponseAPIRegistrationVerify> {
        
        guard let phone = Config.currentUser?.phoneNumber
        else {
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.verify(phone: phone.trimSpaces(), code: code)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationVerify>)
            .map {result in
                
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.setUserName.rawValue,
                    Config.registrationSmsCodeKey: code
                ])
                
                return result
        }
    }
    
    
    /// Resend sms code
    public func resendSmsCode() -> Single<ResponseAPIResendSmsCode> {
        
        guard let phone = Config.currentUser?.phoneNumber else {
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.resendSmsCode(phone: phone.trimSpaces(), isDebugMode: base.isDebugMode)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIResendSmsCode>)
            .map {result in
                
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.verify.rawValue,
                    Config.registrationSmsCodeKey: result.code,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
        }
    }
    
    /// set userName
    public func setUserName(_ name: String) -> Single<ResponseAPIRegistrationSetUsername> {
        
        guard let phone = Config.currentUser?.phoneNumber else {
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.setUser(name: name, phone: phone.trimSpaces())
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationSetUsername>)
            .map {result in
                
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.toBlockChain.rawValue,
                    Config.currentUserNameKey: name
                ])
                
                return result
        }
    }
    
    /// Save user to blockchain
    public func toBlockChain() -> Completable {
        
        guard let id = Config.currentUser?.id,
            let name = Config.currentUser?.name else {
            Logger.log(message: "username missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId missing"))
        }
        
        let masterKey = String.randomString(length: 51)
        let userkeys = generateKeys(userId: id, masterKey: masterKey)
        
        let methodAPIType = MethodAPIType.toBlockChain(user: name, keys: userkeys)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationToBlockChain>)
            .map {result -> ResponseAPIRegistrationToBlockChain in
                
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.registered.rawValue,
                    Config.currentUserNameKey: result.username,
                    Config.currentUserIDKey: result.userId,
                    Config.currentUserMasterKey: masterKey
                ])
                
                try KeychainManager.save(userkeys: userkeys)
                
                return result
            }
//            .flatMap {_ in
//                return self.authorize()
//            }
            .flatMapToCompletable()
    }
    
    /// Set passcode
    public func setPasscode(_ passcode: String, onBoarding: Bool = true) throws {
        guard passcode.count == 4, Int(passcode) != nil else {return}
        var data = [Config.currentUserPasscodeKey: passcode]
        if onBoarding {
            data[Config.settingStepKey] = CurrentUserSettingStep.setFaceId.rawValue
        }
        try KeychainManager.save(data)
    }
    
    /// backupIcloud
    public func backUpICloud(onBoarding: Bool = true) throws {
        iCloudManager.saveUser()
        if onBoarding {
            try KeychainManager.save([
                Config.settingStepKey: CurrentUserSettingStep.setAvatar.rawValue
            ])
        }
    }
    
    /// Login user
    public func login(login: String, masterKey: String, retried: Bool = false) -> Single<ResponseAPIAuthAuthorize> {
        
        var userKeys = [String: UserKeys]()
        var methodAPIType: MethodAPIType!
        
        return base.resolveProfile(username: login)
            .flatMapCompletable({ (profile) -> Completable in
                // Create 4 pairs of keys
                userKeys = self.generateKeys(userId: profile.userId, masterKey: masterKey)
                
                // Authorize request with 1 of 4 keys
                methodAPIType = MethodAPIType.authorize(userID: login, activeKey: userKeys["active"]!.privateKey!)
                
                return self.generateSecret()
            })
            .andThen(Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIAuthAuthorize>)
            .map {result in
                
                try KeychainManager.save(userkeys: userKeys)
                
                try KeychainManager.save([
                    Config.currentUserIDKey: result.user,
                    Config.currentUserNameKey: result.displayName,
                    Config.currentUserMasterKey: masterKey,
                    Config.registrationStepKey: CurrentUserRegistrationStep.relogined.rawValue
                ])
                
                return result
            }
    }
    
    /// Authorize registered user
    public func authorize() -> Single<ResponseAPIAuthAuthorize> {
        
        guard let userId = Config.currentUser?.id,
            let activeKey = Config.currentUser?.activeKeys?.privateKey
        else {
            Logger.log(message: "userId or activeKey missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId or activeKey missing"))
        }
        
        let methodAPIType = MethodAPIType.authorize(userID: userId, activeKey: activeKey)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    /// Logout user
    public func logout() -> Completable {
        let requestParamsType = MethodAPIType.logout.introduced()
        let requestMethodAPIType = Broadcast.instance.prepareGETRequest(requestParamsType: requestParamsType)
        SocketManager.shared.sendMessage(requestMethodAPIType.requestMessage!)
        
        return pushNotifyOff()
            .andThen(Completable.create {completable in
                do {
                    try KeychainManager.deleteUser()
                    UserDefaults.standard.set(nil, forKey: Config.currentUserPushNotificationOn)
                    UserDefaults.standard.set(nil, forKey: Config.currentUserAppLanguageKey)
                    UserDefaults.standard.set(nil, forKey: Config.currentUserThemeKey)
                    UserDefaults.standard.set(nil, forKey: Config.currentUserAvatarUrlKey)
                    UserDefaults.standard.set(nil, forKey: Config.currentUserBiometryAuthEnabled)
                    
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
                return Disposables.create()
            })
    }
    
    /// Generate secret
    public func generateSecret() -> Completable {
        
        let methodAPIType = MethodAPIType.generateSecret
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIAuthGenerateSecret>)
            .flatMapCompletable {result in
                Config.webSocketSecretKey = result.secret
                return .empty()
            }
    }
    
    // MARK: - Private functions
    public func generateKeys(userId: String, masterKey: String) -> [String: UserKeys] {
        var userKeys = [String: UserKeys]()
        
        // type
        let types = ["owner", "active", "posting", "memo"]
        
        for keyType in types {
            let seed                =   userId + keyType + masterKey
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

//
//  Registration+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    static func fixedPhoneNumber(phone: String?) -> String {
        guard let phone = phone else {return ""}
        return "+" + phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "").trimSpaces()
    }
    
    // MARK: - Public function
    /// Get registration state
    public func getState(phone: String? = Config.currentUser?.phoneNumber) -> Single<ResponseAPIRegistrationGetState> {
        
        let methodAPIType = MethodAPIType.getState(phone: RestAPIManager.fixedPhoneNumber(phone: phone))
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationGetState>)
            .map { result in
                // save state
                var dataToSave = [String: Any]()
                
                if let userId = result.data?.userId {
                    dataToSave[Config.currentUserIDKey] = userId
                }
                
                if let username = result.data?.username {
                    dataToSave[Config.currentUserNameKey] = username
                }
                
                if let phone = phone {
                    dataToSave[Config.registrationUserPhoneKey] = phone
                }
                
                dataToSave[Config.registrationStepKey] = result.currentState
                
                try KeychainManager.save(dataToSave)
                
                return result
        }
    }
    
    /// First step of registration
    public func firstStep(phone: String, captchaCode: String) -> Single<ResponseAPIRegistrationFirstStep> {
        let phone = RestAPIManager.fixedPhoneNumber(phone: phone)
        
        let methodAPIType = MethodAPIType.firstStep(phone: phone, captchaCode: captchaCode, isDebugMode: isDebugMode)
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationFirstStep>)
            .map { result in

                var data: [String: Any] = [
                    Config.registrationStepKey: CurrentUserRegistrationStep.verify.rawValue,
                    Config.registrationUserPhoneKey: phone,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ]

                if let code = result.code {
                    data[Config.registrationSmsCodeKey] = code
                }

                try KeychainManager.save(data)
                
                return result
        }
    }
    
    /// Verify code
    public func verify(code: UInt64) -> Single<ResponseAPIRegistrationVerify> {
        guard let phone = Config.currentUser?.phoneNumber else {
            Logger.log(message: "Phone missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "Phone missing"))
        }
        
        let methodAPIType = MethodAPIType.verify(phone: phone, code: code)
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationVerify>)
            .map { result in
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
        
        let methodAPIType = MethodAPIType.resendSmsCode(phone: phone)
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIResendSmsCode>)
            .map { result in
                try KeychainManager.save([
                    Config.registrationStepKey: result.currentState,
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
        
        let methodAPIType = MethodAPIType.setUser(name: name, phone: phone)
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationSetUsername>)
            .map { result in
                guard let userId = result.userId else {
                    throw ErrorAPI.registrationRequestFailed(message: ErrorAPI.Message.couldNotCreateUserId.rawValue, currentStep: result.currentState)
                }
                
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.toBlockChain.rawValue,
                    Config.registrationUserPhoneKey: phone,
                    Config.currentUserNameKey: name,
                    Config.currentUserIDKey: userId
                ])

                return result
        }
    }
    
    /// Save user to blockchain
    public func toBlockChain() -> Completable {
        guard let userName = Config.currentUser?.name, let userID = Config.currentUser?.id, let userPhone = Config.currentUser?.phoneNumber else {
            Logger.log(message: "username missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId missing"))
        }
        
        let masterKey = String.randomString(length: 51)
        let userkeys = generateKeys(userId: userID, masterKey: masterKey)
        let methodAPIType = MethodAPIType.toBlockChain(phone: RestAPIManager.fixedPhoneNumber(phone: userPhone), userID: userID, userName: userName, keys: userkeys)
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIRegistrationToBlockChain>)
            .map { result -> ResponseAPIRegistrationToBlockChain in
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.registered.rawValue,
                    Config.currentUserNameKey: userName,
                    Config.currentUserIDKey: result.userId,
                    Config.currentUserMasterKey: masterKey
                ])
                
                try KeychainManager.save(userkeys: userkeys)
                
                return result
        }
        .flatMapToCompletable()
    }
    
    /// Subscribe to communities on boarding
    public func onboardingCommunitySubscriptions(
        communityIds: [String]
    ) -> Completable {
        guard let userId = Config.currentUser?.id else {return .error(ErrorAPI.unauthorized)}
        guard communityIds.count >= 3 else {return .error(ErrorAPI.other(message: "You must subscribe to at least 3 communities"))}
        let methodAPIType = MethodAPIType.onboardingCommunitySubscriptions(userId: userId, communityIds: communityIds)
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIStatus>)
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
    public func backUpICloud() {
        ICloudManager.saveUser()
    }
    
    /// Login user
    public func login(login: String, masterKey: String, retried: Bool = false) -> Single<ResponseAPIAuthAuthorize> {
        
        var userKeys = [String: UserKeys]()
        
        return resolveProfile(username: login)
            .flatMap({ (profile) -> Single<ResponseAPIAuthAuthorize> in
                // Create 4 pairs of keys
                userKeys = self.generateKeys(userId: profile.userId, masterKey: masterKey)
                
                // Authorize request with 1 of 4 keys
                let methodAPIType = MethodAPIType.authorize(username: login, activeKey: userKeys["active"]!.privateKey!)
                
                return self.generateSecret()
                    .andThen(self.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIAuthAuthorize>)
            })
            .map {result in
                
                try KeychainManager.save(userkeys: userKeys)
                
                try KeychainManager.save([
                    Config.currentUserKey: result.user,
                    Config.currentUserIDKey: result.userId,
                    Config.currentUserNameKey: result.username,
                    Config.currentUserMasterKey: masterKey,
                    Config.registrationStepKey: CurrentUserRegistrationStep.relogined.rawValue
                ])
                
                return result
            }
    }
    
    /// Authorize registered user
    public func authorize() -> Single<ResponseAPIAuthAuthorize> {
        
        guard let username = Config.currentUser?.name,
            let activeKey = Config.currentUser?.activeKeys?.privateKey
        else {
            Logger.log(message: "userId or activeKey missing for user: \(String(describing: Config.currentUser))", event: .error)
            return .error(ErrorAPI.requestFailed(message: "userId or activeKey missing"))
        }
        
        let methodAPIType = MethodAPIType.authorize(username: username, activeKey: activeKey)
        
        return executeGetRequest(methodAPIType: methodAPIType)
            .do(onSuccess: { (_) in
                let requestParamsType = MethodAPIType.notificationsSubscribe.introduced()
                let requestMethodAPIType = self.prepareGETRequest(requestParamsType: requestParamsType)
                SocketManager.shared.sendMessage(requestMethodAPIType.requestMessage!)
            })
    }
    
    /// Logout user
    public func logout() throws {
        // Reset FCM token
        sendMessageIgnoreResponse(methodAPIType: .deviceResetFcmToken)
        
        // logout
        sendMessageIgnoreResponse(methodAPIType: .logout)
        
        // Remove in keychain
        try KeychainManager.deleteUser()
        
        // Remove UserDefaults
        UserDefaults.standard.set(nil, forKey: Config.currentUserAppLanguageKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserThemeKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserAvatarUrlKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserBiometryAuthEnabled)
        UserDefaults.standard.set(nil, forKey: Config.currentUserDidSubscribeToMoreThan3Communities)
        UserDefaults.standard.set(nil, forKey: Config.currentDeviceDidSendFCMToken)
        UserDefaults.standard.set(nil, forKey: Config.currentDeviceDidSetInfo)
        
        // Remove old notifications
        SocketManager.shared.newNotificationsRelay.accept([])
        SocketManager.shared.unseenNotificationsRelay.accept(0)
        
        // rerun socket
        SocketManager.shared.reset()
    }
    
    /// Generate secret
    public func generateSecret() -> Completable {
        
        let methodAPIType = MethodAPIType.generateSecret
        
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIAuthGenerateSecret>)
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

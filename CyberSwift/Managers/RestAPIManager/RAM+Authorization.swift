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
    private func fixedPhoneNumber(phone: String?) -> String? {
        guard let phone = phone else {return nil}
        return "+" + phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "").trimSpaces()
    }
    
    // MARK: - Public function
    /// Get registration state
    public func getState(phone: String? = Config.currentUser?.phoneNumber, identity: String? = Config.currentUser?.identity, email: String? = Config.currentUser?.email) -> Single<ResponseAPIRegistrationGetState> {
        
        let phone = fixedPhoneNumber(phone: phone)
        let methodAPIType = MethodAPIType.getState(phone: phone, identity: identity, email: email)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationGetState>)
            .map { result in
                if result.currentState == "registered" {
                    throw CMError.registration(message: ErrorMessage.accountHasBeenRegistered.rawValue)
                }
                
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
        guard let phone = fixedPhoneNumber(phone: phone) else {
            return .error(CMError.registration(message: ErrorMessage.phoneMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.firstStep(phone: phone, captchaCode: captchaCode, isDebugMode: isDebugMode)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationFirstStep>)
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
    
    public func firstStepEmail(_ email: String, captcha: String) -> Single<ResponseAPIRegistrationFirstStepEmail> {
        let methodAPIType = MethodAPIType.firstStepEmail(email: email, captcha: captcha, isDebugMode: isDebugMode)
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationFirstStepEmail>)
            .map {result in
                var data: [String: Any] = [
                    Config.registrationStepKey: CurrentUserRegistrationStep.verifyEmail.rawValue,
                    Config.currentUserEmailKey: email,
                    Config.registrationEmailNextRetryKey: result.nextEmailRetry
                ]
                if let code = result.code {
                    data[Config.registrationEmailCodeKey] = code
                }
                
                try KeychainManager.save(data)
                
                return result
            }
    }
    
    /// Verify code
    public func verify(code: UInt64) -> Single<ResponseAPIRegistrationVerify> {
        guard let phone = Config.currentUser?.phoneNumber else {
            return .error(CMError.registration(message: ErrorMessage.phoneMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.verify(phone: phone, code: code)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationVerify>)
            .map { result in
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.setUserName.rawValue,
                    Config.registrationSmsCodeKey: code
                ])
                
                return result
        }
    }
    
    public func verifyEmail(code: String) -> Single<ResponseAPIRegistrationVerify> {
        guard let email = Config.currentUser?.email else {
            return .error(CMError.registration(message: ErrorMessage.emailMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.verifyEmail(email: email, code: code)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationVerify>)
            .map {result in
                try KeychainManager.save([
                    Config.registrationStepKey: CurrentUserRegistrationStep.setUserName.rawValue,
                    Config.registrationEmailCodeKey: code
                ])
                
                return result
            }
    }
    
    /// Resend sms code
    public func resendSmsCode() -> Single<ResponseAPIResendSmsCode> {
        guard let phone = Config.currentUser?.phoneNumber else {
            return .error(CMError.registration(message: ErrorMessage.phoneMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.resendSmsCode(phone: phone)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIResendSmsCode>)
            .map { result in
                try KeychainManager.save([
                    Config.registrationStepKey: result.currentState,
                    Config.registrationSmsNextRetryKey: result.nextSmsRetry
                ])
                
                return result
        }
    }
    
    public func resendEmailCode() -> Single<ResponseAPIResendEmailCode> {
        guard let email = Config.currentUser?.email else {
            return .error(CMError.registration(message: ErrorMessage.emailMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.resendEmailCode(email: email)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIResendEmailCode>)
            .map { result in
                try KeychainManager.save([
                    Config.registrationStepKey: result.currentState,
                    Config.registrationEmailNextRetryKey: result.nextEmailRetry
                ])
                
                return result
        }
    }
    
    /// set userName
    public func setUserName(_ name: String) -> Single<ResponseAPIRegistrationSetUsername> {
        let phone = Config.currentUser?.phoneNumber
        let identity = Config.currentUser?.identity
        let email = Config.currentUser?.email

        if phone == nil && identity == nil && email == nil {
            return .error(CMError.registration(message: ErrorMessage.identityMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.setUser(name: name, phone: phone, identity: identity, email: email)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationSetUsername>)
            .map { result in
                guard let userId = result.userId else {
                    throw CMError.registration(message: ErrorMessage.couldNotCreateUserId.rawValue)
                }
                
                var dataToSave: [String: Any] = [
                    Config.registrationStepKey: CurrentUserRegistrationStep.toBlockChain.rawValue,
                    Config.currentUserNameKey: name,
                    Config.currentUserIDKey: userId
                ]
                
                dataToSave[Config.registrationUserPhoneKey] = phone
                dataToSave[Config.currentUserEmailKey] = email
                dataToSave[Config.currentUserIdentityKey] = identity
                
                try KeychainManager.save(dataToSave)

                return result
        }
    }
    
    /// Save user to blockchain
    public func toBlockChain(password: String? = Config.currentUser?.masterKey) -> Completable {
        guard let userName = Config.currentUser?.name, let userID = Config.currentUser?.id else {
            return .error(CMError.registration(message: ErrorMessage.userIdOrUsernameIsMissing.rawValue))
        }

        var phone = Config.currentUser?.phoneNumber
        let identity = Config.currentUser?.identity
        let email = Config.currentUser?.email

        if phone == nil && identity == nil && email == nil {
            return .error(CMError.registration(message: ErrorMessage.identityMissing.rawValue))
        }

        if let userPhone = phone {
            phone = fixedPhoneNumber(phone: userPhone)
        }
        
        let masterKey = password ?? String.randomString(length: 51)
        let userkeys = generateKeys(userId: userID, masterKey: masterKey)
        let methodAPIType = MethodAPIType.toBlockChain(phone: phone, userID: userID, userName: userName, keys: userkeys, identity: identity, email: email)
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIRegistrationToBlockChain>)
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
        guard let userId = Config.currentUser?.id else {return .error(CMError.unauthorized())}
        guard communityIds.count >= 3 else {return .error(CMError.other(message: ErrorMessage.youMustSubscribeToAtLeast3Communities.rawValue))}
        let methodAPIType = MethodAPIType.onboardingCommunitySubscriptions(userId: userId, communityIds: communityIds)
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIStatus>)
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
                    .andThen(self.executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIAuthAuthorize>)
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
            return .error(CMError.invalidRequest(message: ErrorMessage.userIdOrActiveKeyMissing.rawValue))
        }
        
        let methodAPIType = MethodAPIType.authorize(username: username, activeKey: activeKey)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false)
            .do(onSuccess: { (_) in
                let methodAPIType = MethodAPIType.notificationsSubscribe
                self.sendMessageIgnoreResponse(methodAPIType: methodAPIType, authorizationRequired: false)
            })
    }
    
    /// Generate secret
    func generateSecret() -> Completable {
        
        let methodAPIType = MethodAPIType.generateSecret
        
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIAuthGenerateSecret>)
            .flatMapCompletable {result in
                Config.webSocketSecretKey = result.secret
                return .empty()
            }
    }
    
    // MARK: - Private functions
    func generateKeys(userId: String, masterKey: String) -> [String: UserKeys] {
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

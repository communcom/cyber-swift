//
//  CurrentUser.swift
//  CyberSwift
//
//  Created by Chung Tran on 02/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public struct CurrentUser {
    // Main properties
    public let id: String?
    public let name: String?
    public var activeKey: String? {
        return activeKeys?.privateKey
    }
    
    // Registration keys
    public let registrationStep: CurrentUserRegistrationStep
    public let phoneNumber: String?
    public let smsCode: UInt64?
    public let smsNextRetry: String?
    
    // Settings step
    public let settingStep: CurrentUserSettingStep?
    public let passcode: String?
    
    // UsersKey
    public let memoKeys: UserKeys?
    public let ownerKeys: UserKeys?
    public let activeKeys: UserKeys?
    public let postingKeys: UserKeys?
    
    public static func logout() throws {
        try KeychainManager.deleteUser()
        UserDefaults.standard.set(nil, forKey: Config.currentUserPushNotificationOn)
        UserDefaults.standard.set(nil, forKey: Config.currentUserAppLanguageKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserThemeKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserAvatarUrlKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserBiometryAuthEnabled)
        
    }
}

public struct UserKeys {
    public let privateKey: String?
    public let publicKey: String?
}

public enum CurrentUserRegistrationStep: String {
    case firstStep      = "firstStep"
    case verify         = "verify"
    case setUserName    = "setUsername"
    case toBlockChain   = "toBlockChain"
    case registered     = "registered"
}

public enum CurrentUserSettingStep: String {
    case setPasscode    = "setPasscode"
    // FaceId = FaceId or TouchId (optional)
    case setFaceId      = "setFaceId"
    case backUpICloud   = "backUpICloud"
    case setAvatar      = "setAvatar"
    case setBio         = "setBio"
    case completed      = "completed"
}

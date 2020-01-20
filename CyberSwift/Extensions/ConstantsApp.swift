//
//  ConstantsApp.swift
//  CyberSwift
//
//  Created by msm72 on 1/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Starscream
import Foundation

public struct Config {
    public static let appStoreId = "1488928931"
    public static let defaultSymbol = "CMN"
    
    // iPhone X as design template
    public static let heightRatio: CGFloat              =   UIScreen.main.bounds.height / (UIApplication.shared.statusBarOrientation.isPortrait ? 812 : 375)
    public static let widthRatio: CGFloat               =   UIScreen.main.bounds.width / (UIApplication.shared.statusBarOrientation.isPortrait ? 375 : 812)
    
    public static var isAppThemeDark: Bool {
        return UserDefaults.standard.bool(forKey: Config.currentUserThemeKey)
    }
    
    public static let currentDeviceType: String         =   { return UIDevice.modelName.replacingOccurrences(of: " ", with: "-") }()
    
    /// Pagination
    public static let paginationLimit: Int8 = 20
    
    static let blocksBehind: Int = 3
    public static let expireSeconds: Double = 30.0
    
    #if APPSTORE
        static let gate_API_URL: String                     =   "wss://gate.commun.com/"
        static let blockchain_API_URL: String               =   "https://node.commun.com/"
    #else
        static let gate_API_URL: String                     =   "wss://dev-gate.commun.com/"
        static let blockchain_API_URL: String               =   "https://dev-node.commun.com/"
    #endif

    static let imageHost: String                        =   "https://img.commun.com/upload"
    public static let testingPassword: String           =   "machtfrei"
    
    /// Websocket
    public static var webSocketSecretKey: String? {
        get {
            return UserDefaults.standard.string(forKey: "webSocketSecretKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "webSocketSecretKey")
        }
    }
    
    public static var currentUser: CurrentUser? {
        return KeychainManager.currentUser()
    }
    
    public static var appConfig: ResponseAPIGetConfig? {
        get {
            if let savedConfig = UserDefaults.standard.data(forKey: Config.currentUserGetConfig) {
                return try? JSONDecoder().decode(ResponseAPIGetConfig.self, from: savedConfig)
            }
            return nil
        }
        set {
            guard let newValue = newValue else {return}
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: Config.currentUserGetConfig)
            }
        }
    }
    
    /// Check network connection
    public static var isNetworkAvailable: Bool {
        return ReachabilityManager.connection()
    }
    
    /// Keys
    static let userSecretKey: String                        =   "userSecretKey"
    
    // CurrentUser keys
    public static let currentUserKey: String                =   "currentUserKey"
    public static let currentUserIDKey: String              =   "currentUserIDKey"
    public static let currentUserNameKey: String            =   "currentUserNameKey"
    public static let currentUserMasterKey: String          =   "currentUserMasterKey"
    public static let registrationStepKey: String           =   "registrationStepKey"
    public static let settingStepKey: String                =   "settingStepKey"
    public static let registrationSmsCodeKey: String        =   "registrationSmsCodeKey"
    public static let registrationUserPhoneKey: String      =   "registrationUserPhoneKey"
    
    public static let currentUserPasscodeKey: String        =   "currentUserPasscodeKey"
    
    public static let registrationSmsNextRetryKey: String   =   "registrationSmsNextRetryKey"
    public static let currentUserPrivateOwnerKey: String    =   "currentUserPrivateOwnerKey"
    public static let currentUserPublicOwnerKey: String     =   "currentUserPublicOwnerKey"
    public static let currentUserPrivateActiveKey: String   =   "currentUserPrivateActiveKey"
    public static let currentUserPublicActiveKey: String    =   "currentUserPublicActiveKey"
    public static let currentUserPrivatePostingKey: String  =   "currentUserPrivatePostingKey"
    public static let currentUserPublicPostingKey: String   =   "currentUserPublicPostingKey"
    public static let currentUserPrivateMemoKey: String     =   "currentUserPrivateMemoKey"
    public static let currentUserPublickMemoKey: String     =   "currentUserPublickMemoKey"
    
    public static let currentUserAvatarUrlKey: String       =   "currentUserAvatarUrlKey"
    public static let currentUserCoverUrlKey: String        =   "currentUserCoverUrlKey"
    public static let currentUserBiographyKey: String       =   "currentUserBiographyKey"

    public static let currentUserThemeKey: String           =   "currentUserThemeKey"
    public static let currentUserAppLanguageKey: String     =   "currentUserAppLanguageKey"
    
    public static let currentUserPushNotificationOn: String =   "currentUserPushNotificationOn"
    public static let currentUserBiometryAuthEnabled: String =   "currentUserBiometryAuthEnabled"
    public static let currentUserDidSubscribeToMoreThan3Communities: String =   "currentUserDidSubscribeToMoreThan3Communities"
    public static let currentUserGetConfig: String          =   "currentUserGetConfig"
    
    public static let currentDeviceIdKey                    =   "currentDeviceIdKey"
}

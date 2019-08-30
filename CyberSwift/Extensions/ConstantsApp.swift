//
//  ConstantsApp.swift
//  CyberSwift
//
//  Created by msm72 on 1/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Starscream
import Foundation


public struct Config {
    // iPhone X as design template
    public static let heightRatio: CGFloat              =   UIScreen.main.bounds.height / (UIApplication.shared.statusBarOrientation.isPortrait ? 812 : 375)
    public static let widthRatio: CGFloat               =   UIScreen.main.bounds.width / (UIApplication.shared.statusBarOrientation.isPortrait ? 375 : 812)
    
    public static var isAppThemeDark: Bool {
        set { }
        
        get {
            return UserDefaults.standard.bool(forKey: Config.currentUserThemeKey)
        }
    }
    
    public static let currentDeviceType: String         =   { return UIDevice.modelName.replacingOccurrences(of: " ", with: "-") }()
    
    /// Pagination
    public static let paginationLimit: Int8 = 10
    
    static let blocksBehind: Int = 3
    public static let expireSeconds: Double = 30.0
    
    #warning("Which blockchain?")
    public static var isPublicTestnet: Bool             =   true
    
    static let blockchain_API_Address: String               =   isPublicTestnet ? "http://116.202.4.39"   :   "http://46.4.96.246"
    static let blockchain_API_Port: Int32                   =   8888
    static let blockchain_API_URL: String               =   "\(Config.blockchain_API_Address):\(Config.blockchain_API_Port)/"
    
    static let gate_API_IP_Address: String                      =   isPublicTestnet ? "116.203.98.241"   :   "159.69.33.136"
    static let gate_API_IP_Port: Int32                  =   8080
    
    static let gate_API_IP: String                      =   "ws://\(Config.gate_API_IP_Address):\(Config.gate_API_IP_Port)/"
    
    
    // For SwiftSocket
    
    // Don't use!!!
    static let gate_API_URL: String                     =   isPublicTestnet ? "wss://cyber-gate.golos.io/"  :   "wss://gate.commun.com/"
    
    public static let testingPassword: String           =   "machtfrei"
    static let imageHost: String                        =   "https://img.golos.io/upload"
    
    /// Websocket
    public static var webSocketSecretKey: String        =   "Cyberway"
    
    public static var currentUser: CurrentUser? {
        return KeychainManager.currentUser()
    }
    
    /// Check network connection
    public static var isNetworkAvailable: Bool {
        return ReachabilityManager.connection()
    }
    
    
    /// Keys
    static let userSecretKey: String                        =   "userSecretKey"
    
    // CurrentUser keys
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
    
    public static let currentUserThemeKey: String           =   "currentUserThemeKey"
    public static let currentUserAppLanguageKey: String     =   "currentUserAppLanguageKey"
    
    public static let currentUserPushNotificationOn: String =   "currentUserPushNotificationOn"
    public static let currentUserBiometryAuthEnabled:String =   "currentUserBiometryAuthEnabled"
}

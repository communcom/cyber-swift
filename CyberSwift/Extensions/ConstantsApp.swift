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
            return KeychainManager.loadData(forUserNickName: Config.currentUserNickNameKey, withKey: Config.currentUserThemeKey)?[Config.currentUserThemeKey] as? Bool ?? false
        }
    }

    public static let currentDeviceType: String         =   { return UIDevice.modelName.replacingOccurrences(of: " ", with: "-") }()
    public static let smsCodeDebug: UInt64              =   appBuildConfig != .release ? 9999 : 0

    /// Pagination
    public static let paginationLimit: Int8 = 20
    
    static let blocksBehind: Int = 3
    public static let expireSeconds: Double = 30.0
    
    public static var isPublicTestnet: Bool             =   true
    public static let testingPassword: String           =   "DpQad16yDlllEy6"
    static let CHAIN_CYBERWAY_API_BASE_URL: String      =   isPublicTestnet ? "https://node-cyberway.golos.io/" : "http://159.69.85.233:8888/"
    static let imageHost: String                        =   "https://img.golos.io/upload"
    
    /// Websocket
    public static var webSocketSecretKey: String        =   "Cyberway"
    
    public static var currentUser: (nickName: String?, activeKey: String?) {
        set { }
        
        get {
            // User data by phone
            if  let phone       =   UserDefaults.standard.value(forKey: Config.registrationUserPhoneKey) as? String,
                let userData    =   KeychainManager.loadAllData(byUserPhone: phone) {
                let userNickName            =   userData[Config.registrationUserNameKey] as! String
                let userPrivateActiveKey    =   userData[Config.currentUserPrivateActiveKey] as! String
                Logger.log(message: "User data by phone: nickName = \(userNickName)", event: .debug)
                
                return (nickName: userNickName, activeKey: userPrivateActiveKey)
            }
                
            // User data by nickName
            else if let userNickName    =   KeychainManager.loadData(forUserNickName:   Config.currentUserNickNameKey,
                                                                     withKey:           Config.currentUserNickNameKey)?[Config.currentUserNickNameKey] as? String,
                let userActiveKey   =   KeychainManager.loadData(forUserNickName:   Config.currentUserPublicActiveKey,
                                                                 withKey:           Config.currentUserPublicActiveKey)?[Config.currentUserPublicActiveKey] as? String {
                Logger.log(message: "User data by nickName: nickName = \(userNickName)", event: .debug)
                return (nickName: userNickName, activeKey: userActiveKey)
            }
                
            else {
                Logger.log(message: "User nickName is empty", event: .debug)
                return (nickName: nil, activeKey: nil)
            }
        }
    }
    
    public static var currentVoter                      =   (nickName: Config.accountNickTest, activeKey: Config.activeKeyTest)
    public static var currentAuthor                     =   (nickName: Config.accountNickTest, activeKey: Config.activeKeyTest)
    
    // Accounts test values
    public static let accountNickDestroyer2k: String    =   "destroyer2k"
    public static let activeKeyDestroyer2k: String      =   "5JagnCwCrB2sWZw6zCvaBw51ifoQuNaKNsDovuGz96wU3tUw7hJ"
    public static let postingKeyDestroyer2k: String     =   "5JjQWZmWj36xbVdcX96gjMs5BRip7TPPCNFFnm19TPEviqnG5Ke"
    
    static let accountNickMsm72: String                 =   "msm72"
    static let postingKeyMsm72: String                  =   "5Jj6qFdJLGKFFFQbfTwv6JNQmXzCidnjgSFNYKhrgqhzigH4sFp"
    
    static let accountNickNickLick: String              =   "nick.lick"
    static let postingKeyNickLick: String               =   "5HuxaRnfHNTS4HA5EA5SQPqAZogP2GoCuZR2yuL1jdfoqjLZAFD"
    
    static let accountNickYoyoyoyo: String              =   "yoyoyoyo"
    static let postingKeyYoyoyoyo: String               =   "5KUk2QMqYqpFM54YSaNoYLVDTznM3fyA8J8qDUQQNgBnqvVyscC"
    
    static let accountNickJosephKalu: String            =   "joseph.kalu"
    static let postingKeyJosephKalu: String             =   "5K6CfG8gzhTZNwHDxPmeQiPChx6FpgiVYN7USVp2aGC2WsDqH4h"
    
    // testnet: http://116.203.39.126:7777/get_users
    public static let accountNickTest: String           =   "tst2jejxypdx"
    public static let activeKeyTest: String             =   "5HrcdkjaCcXpemf5iXRN6rg4ZtXtDKBWg16gJmfWM7VXTSGWz33"
    
    
    /// Check network connection
    public static var isNetworkAvailable: Bool {
        set { }
        
        get {
            return ReachabilityManager.connection()
        }
    }
    
    
    /// Keys
    static let userSecretKey: String                        =   "userSecretKey"
    public static let currentUserNickNameKey: String        =   "currentUserNickNameKey"
    public static let isCurrentUserLoggedKey: String        =   "isCurrentUserLoggedKey"
    public static let currentUserPrivateOwnerKey: String    =   "currentUserPrivateOwnerKey"
    public static let currentUserPublicOwnerKey: String     =   "currentUserPublicOwnerKey"
    public static let currentUserPrivateActiveKey: String   =   "currentUserPrivateActiveKey"
    public static let currentUserPublicActiveKey: String    =   "currentUserPublicActiveKey"
    public static let currentUserPrivatePostingKey: String  =   "currentUserPrivatePostingKey"
    public static let currentUserPublicPostingKey: String   =   "currentUserPublicPostingKey"
    public static let currentUserPrivateMemoKey: String     =   "currentUserPrivateMemoKey"
    public static let currentUserPublickMemoKey: String     =   "currentUserPublickMemoKey"
    public static let registrationStepKey: String           =   "registrationStepKey"
    public static let registrationSmsCodeKey: String        =   "registrationSmsCodeKey"
    public static let registrationUserPhoneKey: String      =   "registrationUserPhoneKey"
    public static let registrationUserNameKey: String       =   "registrationUserNameKey"
    public static let registrationSmsNextRetryKey: String   =   "registrationSmsNextRetryKey"
    public static let currentUserThemeKey: String           =   "currentUserThemeKey"
}

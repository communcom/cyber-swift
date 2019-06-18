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
            return KeychainManager.loadData(byUserID: Config.currentUserIDKey, withKey: Config.currentUserThemeKey)?[Config.currentUserThemeKey] as? Bool ?? false
        }
    }
    
    public static let currentDeviceType: String         =   { return UIDevice.modelName.replacingOccurrences(of: " ", with: "-") }()
    
    /// Pagination
    public static let paginationLimit: Int8 = 10
    
    static let blocksBehind: Int = 3
    public static let expireSeconds: Double = 30.0
    
    public static var isPublicTestnet: Bool             =   false
    static let blockchain_API_URL: String               =   isPublicTestnet ? "http://116.202.4.39:8888/"   :   "http://46.4.96.246:8888/"
    static let gate_API_IP: String                      =   isPublicTestnet ? "ws://116.203.98.241:8080/"   :   "ws://159.69.33.136:8080/"
    static let gate_API_URL: String                     =   isPublicTestnet ? "wss://cyber-gate.golos.io/"  :   "wss://gate.commun.com/"
    
    public static let testingPassword: String           =   "machtfrei"
    static let imageHost: String                        =   "https://img.golos.io/upload"
    
    /// Websocket
    public static var webSocketSecretKey: String        =   "Cyberway"
    
    public static var currentUser: (id: String?, name: String?, activeKey: String?) {
        set { }
        
        get {
            // User data by phone
            if  let phone       =   UserDefaults.standard.value(forKey: Config.registrationUserPhoneKey) as? String,
                let userData    =   KeychainManager.loadAllData(byUserPhone: phone),
                let step        =   userData[Config.registrationStepKey] as? String, step == "firstStep" {
                let userID                  =   userData[Config.registrationUserIDKey] as! String
                let userName                =   userData[Config.registrationUserNameKey] as! String
                let userPrivateActiveKey    =   userData[Config.currentUserPrivateActiveKey] as! String
                
                Logger.log(message: "User data by phone: userID = \(userID)", event: .debug)
                
                return (id: userID, name: userName, activeKey: userPrivateActiveKey)
            }
                
                // User data by userID
            else if let userIDKey           =   KeychainManager.loadData(byUserID:      Config.currentUserIDKey,
                                                                         withKey:       Config.currentUserIDKey)?[Config.currentUserIDKey] as? String,
                let userNameKey             =   KeychainManager.loadData(byUserID:      Config.currentUserNameKey,
                                                                         withKey:       Config.currentUserNameKey)?[Config.currentUserNameKey] as? String,
                let userActiveKey           =   KeychainManager.loadData(byUserID:      Config.currentUserPublicActiveKey,
                                                                         withKey:       Config.currentUserPublicActiveKey)?[Config.currentUserPublicActiveKey] as? String {
                Logger.log(message: "User data by userID: userID = \(userIDKey)", event: .debug)
                
                return (id: userIDKey, name: userNameKey, activeKey: userActiveKey)
            }
                
            else {
                Logger.log(message: "User nickName is empty", event: .debug)
                
                return (id: nil, name: nil, activeKey: nil)
            }
        }
    }
    
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
    public static let testUserAccount                   =   (
                                                                id:             "tst2waqpylkg",
                                                                alias:          "kuphal-kariane-v",
                                                                activeKey:      "5HtsQ2TEHeCRA3MkYLtX4E2d74ZH4RrvprNeFrK5LjguxEW7MfK",
                                                                ownerKey:       "5Khb6mHXVD1TRa5yvtr6V6oo4eyLAMXnwdMpfJc3vjqwLMqDt1w",
                                                                postingKey:     "5KA4U254wmxxkA7WjReeX5dPw5oAF4qbmG2yPG1gfrRtfd1KVuQ"
                                                            )
    
    public static let testUserAccount2                  =   (
                                                                id:             "tst42gcsapqn",
                                                                alias:          "testuserr1",
                                                                activeKey:      "GLS6HcE3y7oBF6u7Bzg2EB2KyqP3Vn9UwtECHt4PBzcGuKebCcRZ6",
                                                                ownerKey:       "GLS7HQMn7Ab7ccmxGG4ykRqqNM26Xhkk8acTTgqaC8oVY7McZFmur",
                                                                postingKey:     "GLS5ZtKHAPHHpviCjUxb2ec5EdQpuworC6JwoUJXxGkdMyCzswdcy"
                                                            )
    
    public static let testUserAccount3                  =   (
                                                                id:             "tst5rheippil",
                                                                alias:          "gutmann-juliet-sr",
                                                                activeKey:      "5KZkYtJZLt8DFo7D7VG8EDtRsurNpwsCieD1J8dxcfivRY2QAPV",
                                                                ownerKey:       "5KUQAaBNzTbXFnyfovXhxe8LWuwCdx9yR8cjH25Lsw6v6bmdt6Z",
                                                                postingKey:     "5JSvQq5e1SatkaMBtQP4DED1Xc4qLgssy5KHZrwyhFhqMn4RKvJ"
                                                            )
    
    
    /// Check network connection
    public static var isNetworkAvailable: Bool {
        set { }
        
        get {
            return ReachabilityManager.connection()
        }
    }
    
    
    /// Keys
    static let userSecretKey: String                        =   "userSecretKey"
    public static let currentUserNameKey: String            =   "currentUserNameKey"
    public static let currentUserIDKey: String              =   "currentUserIDKey"
    public static let currentUserAvatarUrlKey: String       =   "currentUserAvatarUrlKey"
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
    public static let registrationUserIDKey: String         =   "registrationUserIDKey"
    public static let registrationUserNameKey: String       =   "registrationUserNameKey"
    public static let registrationSmsNextRetryKey: String   =   "registrationSmsNextRetryKey"
    public static let currentUserThemeKey: String           =   "currentUserThemeKey"
}

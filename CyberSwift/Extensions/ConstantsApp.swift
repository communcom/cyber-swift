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
    
    /// Pagination
    public static let paginationLimit: Int8 = 10
    
    static let blocksBehind: Int = 3
    public static let expireSeconds: Double = 30.0
    
    public static var isPublicTestnet: Bool             =   false
    static let blockchain_API_URL: String               =   isPublicTestnet ? "http://116.202.4.39:8888/"   :   "http://46.4.96.246:8888/"
    static let gate_API_IP: String                      =   isPublicTestnet ? "ws://116.203.98.241:8080/"   :   "ws://159.69.33.136:8080/"
    static let gate_API_URL: String                     =   isPublicTestnet ? "wss://cyber-gate.golos.io/"  :   "wss://gate.commun.com/"

    public static let testingPassword: String           =   "DpQad16yDlllEy6"
    static let imageHost: String                        =   "https://img.golos.io/upload"
    
    /// Websocket
    public static var webSocketSecretKey: String        =   "Cyberway"
    
    public static var currentUser: (nickName: String?, activeKey: String?) {
        set { }
        
        get {
            // User data by phone
            if  let phone       =   UserDefaults.standard.value(forKey: Config.registrationUserPhoneKey) as? String,
                let userData    =   KeychainManager.loadAllData(byUserPhone: phone),
                let step        =   userData[Config.registrationStepKey] as? String, step == "firstStep" {
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
                                                                nickName:       "tst2vteffdjg",
                                                                alias:          "zieme-clarabelle-dvm",
                                                                ownerKey:       "5KjkQMk2LxL6hqofx9hgh4AQGkDHBxiapfx1gi4yjbFNc6e2T7V",
                                                                activeKey:      "5J4qUH3mtPAnR6U6ESamcedVfcrx2wu6EfjHbuXDqqrNorh7DCx",
                                                                postingKey:     "5J4DHWmqF2ZQ5gqcjMX1bvqQ8kNEreRYZokfzAyCeDjLsD2TLiM"
                                                            )

    public static let testUserAccount2                  =   (
                                                                nickName:       "tst1kfzmmlqi",
                                                                alias:          "lemke-grady-v",
                                                                ownerKey:       "5J17gV8Sij2yZgWxLCX5us7x9r3sEPmSipPp4fEQdx8FKe7YvjM",
                                                                activeKey:      "5JUzKBRhhsHBApah3N3JEs6b3skRGyTSvbCUkCsWa5C8yyksbxv",
                                                                postingKey:     "5JWNf17VWYhchFcRtGdXMLgZeRtYSS72U2ZsLLnLj6MDjdqdEAU"
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
    public static let currentUserNickNameKey: String        =   "currentUserNickNameKey"
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
    public static let registrationUserNameKey: String       =   "registrationUserNameKey"
    public static let registrationSmsNextRetryKey: String   =   "registrationSmsNextRetryKey"
    public static let currentUserThemeKey: String           =   "currentUserThemeKey"
}

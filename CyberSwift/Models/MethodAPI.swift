//
//  MethodAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//
//  This enum use for GET Requests
//
//  API DOC:                https://github.com/GolosChain/api-documentation
//  FACADE-SERVICE:         https://github.com/GolosChain/facade-service/tree/develop
//  REGISTRATION-SERVICE:   https://github.com/GolosChain/registration-service/tree/develop
//

import Foundation
import Localize_Swift

/// Type of request parameters
typealias RequestMethodParameters   =   (methodAPIType: MethodAPIType, methodGroup: String, methodName: String, parameters: [String: Encodable])

public enum MethodAPIGroup: String {
    case offline            =   "offline"
    case options            =   "options"
    case onlineNotify       =   "onlineNotify"
    case notifications      =   "notifications"
    case push               =   "push"
    case notify             =   "notify"
    case meta               =   "meta"
    case frame              =   "frame"
    case registration       =   "registration"
    case rates              =   "rates"
    case content            =   "content"
    case auth               =   "auth"
    case bandwidth          =   "bandwidth"
    case config             =   "config"
    case wallet             =   "wallet"
    case exchange           =   "exchange"
    case device             =   "device"
    case settings           =   "settings"
    case rewards            =   "rewards"
    case airdrop            =   "airdrop"
    case community          =   "community"
}

public enum FeedTypeMode: String, Codable {
    case new                    =   "new"
    case community              =   "community"
    case subscriptions          =   "subscriptions"
    case byUser                 =   "byUser"
    case topLikes               =   "topLikes"
    case topComments            =   "topComments"
    case topRewards             =   "topRewards"
    case hot                    =   "hot"
    case voted                  =   "voted"
    case subscriptionsHot       =   "subscriptionsHot"
    case subscriptionsPopular   =   "subscriptionsPopular"
    
    public var localizedLabel: String? {
        switch self {
        case .hot, .subscriptionsHot:
            return "hot".localized()
        case .new:
            return "new".localized()
        case .topLikes, .subscriptionsPopular:
            return "popular".localized()
        default:
            return nil
        }
    }
}

public enum FeedTimeFrameMode: String, Codable {
    case day                =   "day"
    case week               =   "week"
    case month              =   "month"
//    case year               =   "year"
    case all                =   "all"
//    case wilsonHot          =   "WilsonHot"
//    case wilsonTrending     =   "WilsonTrending"
    
    public var localizedLabel: String {
        switch self {
        case .day:
            return "past 24 hours".localized()
        case .week:
            return "past week".localized()
        case .month:
            return "past month".localized()
        case .all:
            return "all time".localized()
        }
    }
}

public enum SortBy: String, Codable {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
}

public enum CommentTypeMode: String {
    case user               =   "user"
    case post               =   "post"
}

public enum CommentSortMode: String {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
    case popularity         =   "popularity"
}

public enum GetCommentsType: String {
    case user               =   "user"
    case post               =   "post"
    case replies            =   "replies"
}

public enum RegistrationStategyMode: String {
    case smsFromUser        =   "smsFromUser"
    case smsToUser          =   "smsToUser"
    case mail               =   "mail"
    case social             =   "social"
}

public enum AppProfileType: String {
    case golos              =   "gls"
    case cyber              =   "cyber"
}

public enum GetCommunitiesType: String {
    case all                =   "all"
    case user               =   "user"
}

public enum GetSubscriptionsType: String {
    case user               =   "user"
    case community          =   "community"
}

public enum GetBlacklistType: String {
    case users              =   "users"
    case communities        =   "communities"
}

public enum SearchEntityType: String, Encodable {
    case posts
    case communities
    case profiles
}

public indirect enum MethodAPIType {
    
    //  Waiting for transaction
    case waitForTransaction(id: String)
    
    //  Log out
    case logout
    
    //  Sign out??
    case signout

    //  Subscribe to push notifications
    case notifyPushOn(fcmToken: String, appProfileType: AppProfileType)

    // Unsubscribe of push notifications
    case notifyPushOff(appProfileType: AppProfileType)
    
    //  Subsribe to notification service
    case notificationsSubscribe

    //  Receiving the number of unread notifications according to user settings
    case getPushHistoryFresh
    
    //  Receive user's fresh notifications count
    case getOnlineNotifyHistoryFresh
    
    //  Request for user settings
    case getOptions
    
    //  Set Push/Notify options
    case setNotice(options: RequestParameterAPI.NoticeOptions, type: NoticeType, appProfileType: AppProfileType)

    /// CHAIN-SERVICE
    case bandwidthProvide(chainID: String, transaction: RequestAPITransaction)
    
    /// OTHER
    case getEmbed(url: String)
    
    /// This method return request parameters from selected enum case.
    func introduced() -> RequestMethodParameters {
        switch self {
            
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "content.waitForTransaction", "params": { "transactionId": "OdklASkljlAQafdlkjEoljmasdfkD" } }
        case .waitForTransaction(let id):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "waitForTransaction",
                     parameters:        ["transactionId": id])
            
        
            
        
            
            
        //  Template { "id": 6, "jsonrpc": "2.0", "method": "auth.logout", "params": { "": "" }}
        case .logout:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "logout",
                     parameters:        ["": ""])
            
        case .signout:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "signOut",
                     parameters:        ["": ""])

        //  Template { "id": 71, "jsonrpc": "2.0", "method": "push.notifyOn", "params": { "key": <fcm_token>, "profile": <userNickName-deviceUDID>, "app": <gls> }}
        case .notifyPushOn(let fcmTokenValue, let appProfileType):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "notifyOn",
                     parameters:        [
                                            "app": appProfileType.rawValue,
                                            "key": fcmTokenValue,
                                            "profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                        ])
            
        //  Template { "id": 72, "jsonrpc": "2.0", "method": "push.notifyOff", "params": { "profile": <userNickName-deviceUDID>, "app": <gls> }}
        case .notifyPushOff(let appProfileType):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "notifyOff",
                     parameters:        [
                                            "app": appProfileType.rawValue,
                                            "profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                        ])
            
        case .notificationsSubscribe:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notifications.rawValue,
                     methodName:        "subscribe",
                     parameters:        [:])
            
        //  Template { "id": 8, "jsonrpc": "2.0", "method": "push.historyFresh", "params": { "profile": <userNickName-deviceUDID> }}
        case .getPushHistoryFresh:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "historyFresh",
                     parameters:        ["profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)])
            
        //  Template { "id": 10, "jsonrpc": "2.0", "method": "onlineNotify.historyFresh", "params": {}}
        case .getOnlineNotifyHistoryFresh:
            return (methodAPIType:      self,
                    methodGroup:        MethodAPIGroup.onlineNotify.rawValue,
                    methodName:         "historyFresh",
                    parameters:         [:])
            
        //  Template { "id": 11, "jsonrpc": "2.0", "method": "options.get", "params": { "profile": <userNickName-deviceUDID> }}
        case .getOptions:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.options.rawValue,
                     methodName:        "get",
                     parameters:        ["profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)])

        //  Template { "id": 13, "jsonrpc": "2.0", "method": "options.set", "params": { "profile": <userNickName-deviceUDID>, "push": { "lang": <languageValue>, "show": { "vote": <voteValue>, "flag": <flagValue>, "reply": <replyValue>, "transfer": <transferValue>, "subscribe": <subscribeValue>, "unsubscribe": <unsibscribeValue>, "mention": <mentionValue>, "repost": <repostValue>,  "message": <messageValue>, "witnessVote": <witnessVoteValue>, "witnessCancelVote": <witnessCancelVoteValue>, "reward": <rewardValue>, "curatorReward": <curatorRewardValue> }}}
        case .setNotice(let options, let type, let appProfileType):
            var parameters: [String: Encodable] =  [
                                                    "app": appProfileType.rawValue,
                                                    "profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                                ]

            if type == .push {
                let setNoticeParams = RequestParameterAPI.SetNoticeParams(lang: "en", show: options)
                parameters["push"]      =   setNoticeParams
            }
            
            if type == .notify {
                let setNoticeParams = RequestParameterAPI.SetNoticeParams(lang: nil, show: options)
                
                parameters["notify"]    =   setNoticeParams
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.options.rawValue,
                     methodName:        "set",
                     parameters:        parameters)
        
            
        
            
        // Template: missing
        case .bandwidthProvide(let chainID, let transaction):
            var parameters: [String: Encodable] = ["chainId": chainID]
            parameters["transaction"] = transaction
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.bandwidth.rawValue,
                     methodName:        "provide",
                     parameters:        parameters)
            
        // Template     { "id": 6, "jsonrpc": "2.0", "method": "registration.toBlockChain", "params": { "type": "oembed", "url": "https://www.youtube.com/watch?v=UiYlRkVxC_4" }}
        case .getEmbed(let url):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.frame.rawValue,
                     methodName:        "getEmbed",
                     parameters:        [ "type": "oembed", "url": url ])
            
        
            
        
            
        } // switch
    }
}

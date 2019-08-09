//
//  MethodAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
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
    case push               =   "push"
    case notify             =   "notify"
    case favorites          =   "favorites"
    case meta               =   "meta"
    case frame              =   "frame"
    case registration       =   "registration"
    case rates              =   "rates"
    case content            =   "content"
    case auth               =   "auth"
    case bandwidth          =   "bandwidth"
}

public enum FeedTypeMode: String {
    case community          =   "community"
    case subscriptions      =   "subscriptions"
    case byUser             =   "byUser"
}

public enum FeedTimeFrameMode: String {
    case day                =   "day"
    case week               =   "week"
    case month              =   "month"
    case year               =   "year"
    case all                =   "all"
    case wilsonHot          =   "WilsonHot"
    case wilsonTrending     =   "WilsonTrending"
}

public enum FeedSortMode: String {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
    case popular            =   "popular"
}

public enum CommentTypeMode: String {
    case user               =   "user"
    case post               =   "post"
}

public enum CommentSortMode: String {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
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


public indirect enum MethodAPIType {
    /// FACADE-SERVICE
    //  Getting a user profile
    case getProfile(userID: String, appProfileType: AppProfileType)

    //  Getting tape posts
    case getFeed(typeMode: FeedTypeMode, userID: String?, communityID: String?, timeFrameMode: FeedTimeFrameMode, sortMode: FeedSortMode, paginationSequenceKey: String?)
    
    //  Getting selected post
    case getPost(userID: String, permlink: String)
    
    //  Waiting for transaction
    case waitForTransaction(id: String)
    
    //  Getting user comments feed
    case getUserComments(nickName: String, sortMode: CommentSortMode, limit: Int8, paginationSequenceKey: String?)
    
    //  Getting post comments feed
    case getPostComments(userNickName: String, permlink: String, sortMode: CommentSortMode, limit: Int8, paginationSequenceKey: String?)
    
    //  Log in
    case authorize(userID: String, activeKey: String)

    //  Get the secret authorization to sign
    case generateSecret

    //  Subscribe to push notifications
    case notifyPushOn(fcmToken: String, appProfileType: AppProfileType)

    // Unsubscribe of push notifications
    case notifyPushOff(appProfileType: AppProfileType)

    //  Receiving notifications history
//    case getPushHistory(afterId: String?, limit: UInt, markAsViewed: Bool, freshOnly: Bool, types: String?)

    //  Receiving the number of unread notifications according to user settings
    case getPushHistoryFresh
    
    //  Receive user's notifications
    case getOnlineNotifyHistory(fromId: String?, paginationLimit: Int8, markAsViewed: Bool, freshOnly: Bool)
    
    //  Receive user's fresh notifications count
    case getOnlineNotifyHistoryFresh
    
    //  Request for user settings
    case getOptions
    
    //  Set Basic options
    case setBasicOptions(nsfw: String)
    
    //  Set Push/Notify options
    case setNotice(options: RequestParameterAPI.NoticeOptions, type: NoticeType, appProfileType: AppProfileType)
    
    //  Mark specified notifications as read
    #warning("Not work version")
    case markAsRead(notifies: [String])

    //  Mark all notifications as viewed
    case notifyMarkAllAsViewed

    //  Record the fact of viewing the post
    case recordPostView(permlink: String)

    //  Get current auth user posts
    case getFavorites

    //  Add post to favorites
    case addFavorites(permlink: String)

    //  Remove post from favorites
    case removeFavorites(permlink: String)


    /// REGISTRATION-SERVICE
    //  Get current registration status for user
    case getState(id: String?, phone: String?)
    
    //  First step of registration
    case firstStep(phone: String, isDebugMode: Bool)
    
    //  Second registration step, account verification
    case verify(phone: String, code: UInt64)
    
    //  The third step of registration, account verification
    case setUser(name: String, phone: String)

    //  Re-send of the confirmation code (for the smsToUser strategy)
    case resendSmsCode(phone: String, isDebugMode: Bool)
    
    //  The last step of registration, entry in the blockchain
    case toBlockChain(user: String, keys: [String: UserKeys])

    /// CHAIN-SERVICE
    case bandwidthProvide(chainID: String, transaction: String)
    
    /// This method return request parameters from selected enum case.
    func introduced() -> RequestMethodParameters {
        switch self {
        /// FACADE-SERVICE
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "content.getProfile", "params": { "userId": "tst3uuqzetwf" }}
        case .getProfile(let userIDValue, let appProfileType):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getProfile",
                     parameters:        ["userId": userIDValue, "app": appProfileType.rawValue])

        //  Template { "id": 2, "jsonrpc": "2.0", "method": "content.getFeed", "params": { "type": "community", "timeframe": "day", "sortBy": "popular", "limit": 20, "userId": "tst3uuqzetwf", "communityId": "gls" }}
        case .getFeed(let typeModeValue, let userNickNameValue, let communityIDValue, let timeFrameModeValue, let sortModeValue, let paginationSequenceKeyValue):
            var parameters: [String: Encodable] = ["type": typeModeValue.rawValue, "timeframe": timeFrameModeValue.rawValue, "sortBy": sortModeValue.rawValue, "limit": Config.paginationLimit]
            
            if let userIDValue = userNickNameValue {
                parameters["userId"] = userIDValue
            }
            
            if let communityIDValue = communityIDValue {
                parameters["communityId"] = communityIDValue
            }
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getFeed",
                     parameters:        parameters)
            
        //  Template { "id": 3, "jsonrpc": "2.0", "method": "content.getPost", "params": { "userId": "tst2nbduouxh", "permlink": "hephaestusfightswithantigoneagainststyx", "refBlockNum": 381607 }}
        case .getPost(let userNickNameValue, let permlinkValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getPost",
                     parameters:        ["userId": userNickNameValue, "permlink": permlinkValue])
            
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "content.waitForTransaction", "params": { "transactionId": "OdklASkljlAQafdlkjEoljmasdfkD" } }
        case .waitForTransaction(let id):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "waitForTransaction",
                     parameters:        ["transactionId": id])
            
        //  Template { "id": 4, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "user", "userId": "tst2nbduouxh", "sortBy": "time", "limit": 20 }}
        case .getUserComments(let userNickNameValue, let sortModeValue, let limit, let paginationSequenceKeyValue):
            var parameters: [String: Encodable] = ["type": "user", "userId": userNickNameValue, "sortBy": sortModeValue.rawValue, "limit": limit]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        //  Template { "id": 5, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "post", "userId": "tst1xrhojmka", "sortBy": "time", "permlink":  "demeterfightswithandromedaagainstepimetheus", "refBlockNum": "520095", "limit": 20 }}
        case .getPostComments(let userNickNameValue, let permlinkValue, let sortModeValue, let limit, let paginationSequenceKeyValue):
            var parameters: [String: Encodable] = ["type": "post", "userId": userNickNameValue, "permlink": permlinkValue, "sortBy": sortModeValue.rawValue, "limit": limit]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        //  Template { "id": 6, "jsonrpc": "2.0", "method": "auth.authorize", "params": { "user": "tst1xrhojmka", "sign": "Cyberway" }}
        case .authorize(let userIDValue, let activeKeyValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "authorize",
                     parameters:        ["user": userIDValue, "secret": Config.webSocketSecretKey, "sign": EOSManager.signWebSocketSecretKey(userActiveKey: activeKeyValue) ?? "Cyberway"])

        //  Template { "id": 7, "jsonrpc": "2.0", "method": "auth.generateSecret", "params": { "": "" }}
        case .generateSecret:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "generateSecret",
                     parameters:        ["": ""])

        //  Template { "id": 71, "jsonrpc": "2.0", "method": "push.notifyOn", "params": { "key": <fcm_token>, "profile": <userNickName-deviceUDID>, "app": <gls> }}
        case .notifyPushOn(let fcmTokenValue, let appProfileType):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "notifyOn",
                     parameters:        [
                                            "app":      appProfileType.rawValue,
                                            "key":      fcmTokenValue,
                                            "profile":  String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                        ])
            
        //  Template { "id": 72, "jsonrpc": "2.0", "method": "push.notifyOff", "params": { "profile": <userNickName-deviceUDID>, "app": <gls> }}
        case .notifyPushOff(let appProfileType):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "notifyOff",
                     parameters:        [
                                            "app":      appProfileType.rawValue,
                                            "profile":  String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                        ])
            
        //  Template { "id": 8, "jsonrpc": "2.0", "method": "push.historyFresh", "params": { "profile": <userNickName-deviceUDID> }}
        case .getPushHistoryFresh:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "historyFresh",
                     parameters:        ["profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)])
            
        //  Template { "id": 9, "jsonrpc": "2.0", "method": "onlineNotify.history", "params": { "freshOnly": true, "fromId": "3123", markAsViewed}}
        case .getOnlineNotifyHistory(let fromId, _, let markAsViewed, let freshOnly):
            var parameters: [String: Encodable] = ["limit": Config.paginationLimit, "markAsViewed": markAsViewed, "freshOnly": freshOnly]
            
            if let fromId = fromId {
                parameters["fromId"] = fromId
            }
            
            return (methodAPIType:      self,
                    methodGroup:        MethodAPIGroup.onlineNotify.rawValue,
                    methodName:         "history",
                    parameters:         parameters)
            
        //  Template { "id": 10, "jsonrpc": "2.0", "method": "onlineNotify.historyFresh", "params": {}}
        case .getOnlineNotifyHistoryFresh:
            return (methodAPIType:      self,
                    methodGroup:        MethodAPIGroup.onlineNotify.rawValue,
                    methodName:         "historyFresh",
                    parameters:         [:])
            
        //  Template { "id": 11, "jsonrpc": "2.0", "result": { "status": "OK" } }
        case .notifyMarkAllAsViewed:
            return (methodAPIType:      self,
                    methodGroup:        MethodAPIGroup.notify.rawValue,
                    methodName:         "markAllAsViewed",
                    parameters:         [:])
            
        //  Template { "id": 11, "jsonrpc": "2.0", "method": "options.get", "params": { "profile": <userNickName-deviceUDID> }}
        case .getOptions:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.options.rawValue,
                     methodName:        "get",
                     parameters:        ["profile": String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)])

        //  Template { "id": 12, "jsonrpc": "2.0", "method": "options.set", "params": { "profile": <userNickName-deviceUDID>, "basic": { "language": "ru", "nsfwContent": "Always alert" }}}
        case .setBasicOptions(let nsfw):
            let appLanguage = UserDefaults.standard.value(forKey: Config.currentUserAppLanguageKey) as? String ?? "en"
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.options.rawValue,
                     methodName:        "set",
                     parameters:        [
                                            "profile":  String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType),
                                            "basic":    String(format: "{\"language\": \"%@\", \"nsfwContent\": \"%@\"}", appLanguage, nsfw)
                                        ])

        //  Template { "id": 13, "jsonrpc": "2.0", "method": "options.set", "params": { "profile": <userNickName-deviceUDID>, "push": { "lang": <languageValue>, "show": { "vote": <voteValue>, "flag": <flagValue>, "reply": <replyValue>, "transfer": <transferValue>, "subscribe": <subscribeValue>, "unsubscribe": <unsibscribeValue>, "mention": <mentionValue>, "repost": <repostValue>,  "message": <messageValue>, "witnessVote": <witnessVoteValue>, "witnessCancelVote": <witnessCancelVoteValue>, "reward": <rewardValue>, "curatorReward": <curatorRewardValue> }}}
        case .setNotice(let options, let type, let appProfileType):
            var parameters: [String: Encodable] =  [
                                                    "app":      appProfileType.rawValue,
                                                    "profile":  String(format: "%@-%@", Config.currentUser?.id ?? "", Config.currentDeviceType)
                                                ]

            if type == .push {
                var pushLanguage = Localize.currentLanguage()
                #warning("supporting only Russian and English")
                if pushLanguage != "ru", pushLanguage != "en" {pushLanguage = "en"}
                
                let setNoticeParams = RequestParameterAPI.SetNoticeParams(lang: pushLanguage, show: options)
                
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

        //  Template { "id": 14, "jsonrpc": "2.0", "method": "notify.markAsRead", "params": { "user": <userNickName>, "params": { "vote": <voteValue>, "flag": <flagValue>, "reply": <replyValue>, "transfer": <transferValue>, "subscribe": <subscribeValue>, "unsubscribe": <unsibscribeValue>, "mention": <mentionValue>, "repost": <repostValue>,  "message": <messageValue>, "witnessVote": <witnessVoteValue>, "witnessCancelVote": <witnessCancelVoteValue>, "reward": <rewardValue>, "curatorReward": <curatorRewardValue> }}}
        #warning("Not work version")
        case .markAsRead(let notifies):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notify.rawValue,
                     methodName:        "markAsRead",
                     parameters:        ["ids": notifies])

        //  Template { "id": 15, "jsonrpc": "2.0", "method": "meta.recordPostView", "params": { "postLink": <author.permlink>, "fingerPrint": <deviceUDID> }}
        case .recordPostView(let permlink):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.meta.rawValue,
                     methodName:        "recordPostView",
                     parameters:        ["postLink": permlink, "fingerPrint": Config.currentDeviceType])
            
        //  Template { "id": 16, "jsonrpc": "2.0", "method": "favorites.get", "params": { "user": <userNickName> }}
        case .getFavorites:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.favorites.rawValue,
                     methodName:        "get",
                     parameters:        ["user": Config.currentUser?.id ?? ""])

        //  Template { "id": 17, "jsonrpc": "2.0", "method": "favorites.add", "params": { "permlink": <selectedPostPermlink> }}
        case .addFavorites(let permlink):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.favorites.rawValue,
                     methodName:        "add",
                     parameters:        ["permlink": permlink])

        //  Template { "id": 18, "jsonrpc": "2.0", "method": "favorites.remove", "params": { "permlink": <selectedPostPermlink> }}
        case .removeFavorites(let permlink):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.favorites.rawValue,
                     methodName:        "remove",
                     parameters:        ["permlink": permlink])


        /// REGISTRATION-SERVICE
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "registration.getState", "params": { "phone": "+70000000000" }}
        case .getState(let idValue, let phoneValue):
            var parameters = [String: Encodable]()
            
            if idValue != nil {
                parameters["user"] = idValue!
            }
            
            if phoneValue != nil {
                parameters["phone"] = phoneValue!
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "getState",
                     parameters:        parameters)

        //  Debug template      { "id": 2, "jsonrpc": "2.0", "method": "registration.firstStep", "params": { "phone": "+70000000000", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 2, "jsonrpc": "2.0", "method": "registration.firstStep", "params": { "phone": "+70000000000" }}
        case .firstStep(let phoneValue, let isDebugMode):
            var parameters = ["phone": phoneValue]

            if isDebugMode {
                parameters["testingPass"] = Config.testingPassword
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "firstStep",
                     parameters:        parameters)

        //  { "id": 3, "jsonrpc": "2.0", "method": "registration.verify", "params": { "phone": "+70000000000", "code": "1563" }}
        case .verify(let phoneValue, let codeValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "verify",
                     parameters:        ["phone": phoneValue, "code": "\(codeValue)"])
            
        //  { "id": 4, "jsonrpc": "2.0", "method": "registration.setUsername", "params": { "user": "tester", "phone": "+70000000000" }}
        case .setUser(let name, let phoneValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "setUsername",
                     parameters:        ["phone": phoneValue, "user": name])

        //  Debug template      { "id": 5, "jsonrpc": "2.0", "method": "registration.resendSmsCode", "params": { "phone": "+70000000000", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 5, "jsonrpc": "2.0", "method": "registration.resendSmsCode", "params": { "phone": "+70000000000" }}
        case .resendSmsCode(let phoneValue, let isDebugMode):
            var parameters = ["phone": phoneValue]
            
            if isDebugMode {
                parameters["testingPass"] = Config.testingPassword
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "resendSmsCode",
                     parameters:        parameters)

            //  Template    { "id": 6, "jsonrpc": "2.0", "method": "registration.toBlockChain", "params": { "user": "tester", "owber": "5HtBPHEhgRmZpAR7EtF3NwG5wVzotNGHBBFo8CF6kucwqeiatpw", "active": "5K4bqcDKtveY8JA3saNkqmCsv18JQsxKf7LGU27nLPzigCmCK69", "posting": "5KPcWDsxka9MEZYBspFqFJueq2L7hgFxWTNkhxoqf1iFYJwZXYD", "memo": "5Kgn17ZFaJVzYVY3Mc8H99MuwqhECA7EWwkbDC7EZgFAjHAEtvS" }}
        case .toBlockChain(let user, let keysValues):
            var parameters = ["user": user]

            if let ownerUserKey = keysValues["owner"] {
                parameters["owner"] = ownerUserKey.publicKey
            }

            if let activeUserKey = keysValues["active"] {
                parameters["active"] = activeUserKey.publicKey
            }

            if let postingUserKey = keysValues["posting"] {
                parameters["posting"] = postingUserKey.publicKey
            }

            if let memoUserKey = keysValues["memo"] {
                parameters["memo"] = memoUserKey.publicKey
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "toBlockChain",
                     parameters:        parameters)
            
            
        // Template: missing
        case .bandwidthProvide(let chainID, let transaction):
            var parameters = ["chainId": chainID]
            parameters["transaction"] = transaction
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.bandwidth.rawValue,
                     methodName:        "provide",
                     parameters:        parameters)
        } // switch
        
        
    }
}

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
    /// FACADE-SERVICE
    
    //  Get user's black list
    case getBlacklist(userId: String?, type: GetBlacklistType, limit: Int, offset: Int)
    
    //  Get posts
    case getPosts(userId: String?, communityId: String?, communityAlias: String? = nil, allowNsfw: Bool?, type: FeedTypeMode, sortBy: SortBy?, timeframe: FeedTimeFrameMode?, limit: UInt, offset: UInt, allowedLanguages: [String])
    
    //  Getting selected post
    case getPost(userId: String?, username: String?, permlink: String, communityId: String?, communityAlias: String?)
    
    //  Waiting for transaction
    case waitForTransaction(id: String)
    
    case getComment(userId: String, permlink: String, communityId: String)
    
    //  Get referral users
    case getReferralUsers(limit: UInt, offset: UInt)
    
    //  Enter promo code
    case appendReferralParent(refferalId: String, phone: String?, identity: String?, email: String?, userId: String?)
    
    //  Log in
    case authorize(username: String, activeKey: String)
    
    //  Log out
    case logout
    
    //  Sign out??
    case signout

    //  Get the secret authorization to sign
    case generateSecret

    //  Subscribe to push notifications
    case notifyPushOn(fcmToken: String, appProfileType: AppProfileType)

    // Unsubscribe of push notifications
    case notifyPushOff(appProfileType: AppProfileType)
    
    //  Subsribe to notification service
    case notificationsSubscribe

    //  Receiving notifications
    case getNotifications(limit: UInt, beforeThan: String?, filter: [String]?)
    
    //  Notification getStatus
    case notificationsGetStatus
    
    //  Get Push notifications settings
    case getPushSettings
    
    //  Set push notifications settings
    case setPushSettings(disabled: [String])

    //  Receiving the number of unread notifications according to user settings
    case getPushHistoryFresh
    
    //  Receive user's fresh notifications count
    case getOnlineNotifyHistoryFresh
    
    //  Request for user settings
    case getOptions
    
    //  Set Push/Notify options
    case setNotice(options: RequestParameterAPI.NoticeOptions, type: NoticeType, appProfileType: AppProfileType)
    
    //  Mark specified notifications as read
    case markAsRead([String])
    
    //  Mark all as viewed
    case markAllAsViewed(until: String)

    //  Record the fact of viewing the post
    case recordPostView(permlink: String)
    
    //  Get community
    case getCommunity(id: String? = nil, alias: String? = nil)
    
    //  Get communities list
    case getCommunities(type: GetCommunitiesType?, userId: String?, offset: Int?, limit: Int?)
    
    //  Get leaders
    case getLeaders(communityId: String?, communityAlias: String?, sequenceKey: String?, limit: Int, query: String?)
    
    //  Get community black list
    case getCommunityBlacklist(communityId: String, limit: Int, offset: Int)
    
    /// REGISTRATION-SERVICE
    //  Get current registration status for user
    case getState(phone: String?, identity: String?, email: String?)
    
    //  First step of registration
    //  Modify: add `captchaType` (https://github.com/communcom/commun/issues/929)
    case firstStep(phone: String, captchaCode: String, isDebugMode: Bool)
    
    case firstStepEmail(email: String, captcha: String, isDebugMode: Bool)
    
    //  Second registration step, account verification
    case verify(phone: String, code: UInt64)
    
    case verifyEmail(email: String, code: String)
    
    //  The third step of registration, account verification
    case setUser(name: String, phone: String?, identity: String?, email: String?)

    //  Re-send of the confirmation code (for the smsToUser strategy)
    case resendSmsCode(phone: String)
    
    case resendEmailCode(email: String)
    
    //  The last step of registration, entry in the blockchain
//    case toBlockChain(user: String, keys: [String: UserKeys])
    case toBlockChain(phone: String?, userID: String, userName: String, keys: [String: UserKeys], identity: String?, email: String?)
    
    //  Onboarding step to force user to subscribe to at least 3 communities
    case onboardingCommunitySubscriptions(userId: String, communityIds: [String])
    
    /// Config
    case getConfig
    
    /// WALLET
    case getTransferHistory(userId: String?, direction: String, transferType: String?, symbol: String?, rewards: String?, donation: String?, claim: String?, holdType: String?, offset: UInt, limit: UInt)
    
    case getBalance(userId: String?)
    
    case getBuyPrice(pointSymbol: String, quantity: String)
    
    case getSellPrice(quantity: String)
    
    case getCurrenciesFull

    /// DEVICE
    case deviceSetInfo(timeZoneOffset: Int)
    
    case deviceSetFcmToken(_ token: String)
    
    case deviceResetFcmToken
    
    case getMinMaxAmount(from: String, to: String)
    
    case getExchangeAmount(from: String, to: String, amount: Double)
    
    case createTransaction(from: String, address: String, amount: String, extraId: String?, refundAddress: String?, refundExtraId: String?)
    
    /// REWARDS
    case rewardsGetStateBulk(posts: [RequestAPIContentId])
    
    /// DONATIONS
    case getDonationsBulk(posts: [RequestAPIContentId])
    
    /// SEARCH
    case quickSearch(queryString: String, entities: [SearchEntityType], limit: UInt)
    
    case extendedSearch(queryString: String, entities: [SearchEntityType: [String: UInt]])
    
    case entitySearch(queryString: String, entity: SearchEntityType, limit: UInt, offset: UInt)
    
    /// SETTINGS
    case getUserSettings
    
    /// AIRDROP
    case getAirdrop(communityId: String)

    /// CHAIN-SERVICE
    case bandwidthProvide(chainID: String, transaction: RequestAPITransaction)
    
    /// OTHER
    case getEmbed(url: String)
    
    /// COMMUNITY MANAGER
    case getProposals(communityIds: [String], limit: Int, offset: Int)
    
    case getReportsList(communityIds: [String], contentType: String, status: String, sortBy: SortBy, limit: Int, offset: Int)
    
    case getEntityReports(userId: String, communityId: String, permlink: String, limit: Int, offset: Int)
    
    /// COMMUNITY CREATION
    case createNewCommunity(name: String)
    
    case communitySetSettings(name: String, avatarUrl: String, coverUrl: String, language: String, description: String, rules: String, subject: String, communityId: String)
    
    case startCommunityCreation(communityId: String, transferTrxId: String?)
    
    case getUsersCommunity
    
    /// This method return request parameters from selected enum case.
    func introduced() -> RequestMethodParameters {
        switch self {
        /// FACADE-SERVICE

        case .getBlacklist(let userId, let type, _, _):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getBlacklist",
                     parameters:        ["userId": userId, "type": type.rawValue/*, "limit": limit, "offset": offset*/])

        //  Template { "id": 2, "jsonrpc": "2.0", "method": "content.getFeed", "params": { "type": "community", "timeframe": "day", "sortBy": "popular", "limit": 20, "userId": "tst3uuqzetwf", "communityId": "gls" }}
        case .getPosts(let userId, let communityId, let communityAlias, let allowNsfw, let type, let sortBy, let timeframe, let limit, let offset, let allowedLanguages):
            var parameters = [String: Encodable]()
            parameters["userId"]            = userId
            parameters["communityId"]       = communityId
            parameters["communityAlias"]    = communityAlias
            parameters["allowNsfw"]         = allowNsfw ?? false
            parameters["type"]              = type.rawValue
            if type != .new {
                parameters["sortBy"]        = sortBy?.rawValue
            }
            if type == .topLikes || type == .topComments || type == .topRewards || type == .subscriptionsPopular {
                parameters["timeframe"]     = timeframe?.rawValue
            }
            parameters["limit"]             = limit
            parameters["offset"]            = offset
            
            parameters["allowedLanguages"] = allowedLanguages
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getPosts",
                     parameters:        parameters)
            
        //  Template { "id": 3, "jsonrpc": "2.0", "method": "content.getPost", "params": { "userId": "tst2nbduouxh", "permlink": "hephaestusfightswithantigoneagainststyx", "refBlockNum": 381607 }}
        case .getPost(let userId, let username, let permlink, let communityId, let communityAlias):
            var parameters = [String: Encodable]()
            parameters["userId"] = userId
            parameters["username"] = username
            parameters["permlink"] = permlink
            parameters["communityId"] = communityId
            parameters["communityAlias"] = communityAlias
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getPost",
                     parameters:        parameters)
            
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "content.waitForTransaction", "params": { "transactionId": "OdklASkljlAQafdlkjEoljmasdfkD" } }
        case .waitForTransaction(let id):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "waitForTransaction",
                     parameters:        ["transactionId": id])
            
        //  Template { "id": 4, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "user", "userId": "tst2nbduouxh", "sortBy": "time", "limit": 20 }}
            
        case .getComment(let userId, let permlink, let communityId):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComment",
                     parameters:        ["userId": userId, "permlink": permlink, "communityId": communityId])
            
        case .getReferralUsers(let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getReferralUsers",
                     parameters:        ["limit": limit, "offset": offset])
            
        case .appendReferralParent(let refferalId, let phone, let identity, let email, let userId):
            var params: [String: Encodable] = ["referralId": refferalId]
            params["phone"] = phone
            params["identity"] = identity
            params["email"] = email
            params["userId"] = userId
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "appendReferralParent",
                     parameters:        params)
            
        //  Template { "id": 6, "jsonrpc": "2.0", "method": "auth.authorize", "params": { "user": "tst1xrhojmka", "sign": "Cyberway" }}
        case .authorize(let username, let activeKeyValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "authorize",
                     parameters:        ["user": username, "secret": Config.webSocketSecretKey, "sign": EOSManager.signWebSocketSecretKey(userActiveKey: activeKeyValue) ?? "Cyberway"])
            
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

        //  Template { "id": 7, "jsonrpc": "2.0", "method": "auth.generateSecret", "params": { "": "" }}
        case .generateSecret:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "generateSecret",
                     parameters:        [:])

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
            
        case .notificationsGetStatus:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notifications.rawValue,
                     methodName:        "getStatus",
                     parameters:        [:])
            
        case .getPushSettings:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.settings.rawValue,
                     methodName:        "getPushSettings",
                     parameters:        [:])
            
        case .setPushSettings(let disabled):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.settings.rawValue,
                     methodName:        "setPushSettings",
                     parameters:        ["disable": disabled])
            
        case .getNotifications(let limit, let beforeThan, let filter):
            var params = [String: Encodable]()
            params["limit"] = limit
            params["beforeThan"] = beforeThan
            if let filter = filter, filter.count > 0 {
                params["filter"] = filter
            }
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notifications.rawValue,
                     methodName:        "getNotifications",
                     parameters:        params)
            
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

        case .markAsRead(let notifies):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notifications.rawValue,
                     methodName:        "markAsRead",
                     parameters:        ["ids": notifies])
            
        case .markAllAsViewed(let until):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.notifications.rawValue,
                     methodName:        "markAllAsViewed",
                     parameters:        ["until": until])
            
        //  Template { "id": 15, "jsonrpc": "2.0", "method": "meta.recordPostView", "params": { "postLink": <author.permlink>, "fingerPrint": <deviceUDID> }}
        case .recordPostView(let permlink):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.meta.rawValue,
                     methodName:        "recordPostView",
                     parameters:        ["postLink": permlink, "fingerPrint": Config.currentDeviceType])
            
        //  Template { "id": 16, "jsonrpc": "2.0", "method": "favorites.get", "params": { "user": <userNickName> }}
            
        case .getCommunity(let id, let alias):
            var params = [String: Encodable]()
            params["communityId"] = id
            params["communityAlias"] = alias
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getCommunity",
                     parameters:        params)
            
        case .getCommunities(let type, let userId, let offset, let limit):
            var params = [String: Encodable]()
            params["type"] = type?.rawValue
            if type == .user {
                params["userId"] = userId
            }
            params["offset"] = offset
            params["limit"] = limit
            params["allowedLanguages"] = ["all"]
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getCommunities",
                     parameters:        params)
            
        case .getLeaders(let communityId, let communityAlias, let sequenceKey, let limit, let query):
            var params = [String: Encodable]()
            params["communityId"]       = communityId
            params["communityAlias"]    = communityAlias
            params["limit"]             = limit
            params["sequenceKey"]       = sequenceKey
            params["query"]             = query
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getLeaders",
                     parameters:        params)
        case .getCommunityBlacklist(let communityId, let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getCommunityBlacklist",
                     parameters:        ["communityId": communityId, "limit": limit, "offset": offset])

        /// REGISTRATION-SERVICE
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "registration.getState", "params": { "phone": "+70000000000" }}
        case .getState(let phoneValue, let identity, let email):
            var parameters = [String: Encodable]()
            
            if let phone = phoneValue {
                parameters["phone"] = phone
            }

            if let identity = identity {
                parameters["identity"] = identity
            }
            
            if let email = email {
                parameters["email"] = email
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "getState",
                     parameters:        parameters)

        //  Debug template      { "id": 2, "jsonrpc": "2.0", "method": "registration.firstStep", "params": { "phone": "+70000000000", "captcha": <captcha_code>, "captchaType": "ios", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 2, "jsonrpc": "2.0", "method": "registration.firstStep", "params": { "phone": "+70000000000", "captcha": <captcha_code>, "captchaType": "ios" }}
        case .firstStep(let phoneValue, let captchaCode, let isDebugMode):
            var parameters = ["phone": phoneValue, "captcha": captchaCode, "captchaType": "ios" ]

            if isDebugMode {
                parameters["testingPass"]   =   Config.testingPassword
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "firstStep",
                     parameters:        parameters)
            
        case .firstStepEmail(let email, let captcha, let isDebugMode):
            var parameters = ["email": email, "captcha": captcha, "captchaType": "ios" ]

            if isDebugMode {
                parameters["testingPass"]   =   Config.testingPassword
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "firstStepEmail",
                     parameters:        parameters)

        //  { "id": 3, "jsonrpc": "2.0", "method": "registration.verify", "params": { "phone": "+70000000000", "code": "1563" }}
        case .verify(let phoneValue, let codeValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "verify",
                     parameters:        ["phone": phoneValue, "code": codeValue])
            
        case .verifyEmail(let email, let code):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "verifyEmail",
                     parameters:        ["email": email, "code": code])
            
        //  { "id": 4, "jsonrpc": "2.0", "method": "registration.setUsername", "params": { "username": "tester", "phone": "+70000000000" }}
        case .setUser(let name, let phone, let identity, let email):
            var params = ["username": name]
            params["phone"] = phone
            params["identity"] = identity
            params["email"] = email

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "setUsername",
                     parameters:        params)

        //  Debug template      { "id": 5, "jsonrpc": "2.0", "method": "registration.resendSmsCode", "params": { "phone": "+70000000000", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 5, "jsonrpc": "2.0", "method": "registration.resendSmsCode", "params": { "phone": "+70000000000" }}
        case .resendSmsCode(let phoneValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "resendSmsCode",
                     parameters:        ["phone": phoneValue])

        //  Template    { "id": 6, "jsonrpc": "2.0", "method": "registration.toBlockChain", "params": { "user": "tester", "owber": "5HtBPHEhgRmZpAR7EtF3NwG5wVzotNGHBBFo8CF6kucwqeiatpw", "active": "5K4bqcDKtveY8JA3saNkqmCsv18JQsxKf7LGU27nLPzigCmCK69", "posting": "5KPcWDsxka9MEZYBspFqFJueq2L7hgFxWTNkhxoqf1iFYJwZXYD", "memo": "5Kgn17ZFaJVzYVY3Mc8H99MuwqhECA7EWwkbDC7EZgFAjHAEtvS" }}
            
        case .resendEmailCode(let email):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "resendEmailCode",
                     parameters:        ["email": email])
            
        case .toBlockChain(let phone, let userIdValue, let userNameValue, let keysValues, let identity, let email):
            var parameters = ["userId": userIdValue, "username": userNameValue]
            
            parameters["phone"] = phone
            parameters["identity"] = identity
            parameters["email"] = email

            if let ownerUserKey = keysValues["owner"] {
                parameters["publicOwnerKey"] = ownerUserKey.publicKey
            }

            if let activeUserKey = keysValues["active"] {
                parameters["publicActiveKey"] = activeUserKey.publicKey
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        CurrentUserRegistrationStep.toBlockChain.rawValue,
                     parameters:        parameters)

        case .onboardingCommunitySubscriptions(let userId, let communityIds):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "onboardingCommunitySubscriptions",
                     parameters:        [
                        "userId": userId,
                        "communityIds": communityIds
                    ])
            
        case .getConfig:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.config.rawValue,
                     methodName:        "getConfig",
                     parameters:        [:])
            
        case .getTransferHistory(let userId, let direction, let transferType, let symbol, let rewards, let donation, let claim, let holdType, let offset, let limit):
            var parameters = [String: Encodable]()
            parameters["userId"] = userId
            parameters["direction"] = direction
            parameters["transferType"] = transferType
            parameters["symbol"] = symbol
            parameters["rewards"] = rewards
            parameters["claim"] = claim
            parameters["donation"] = donation
            parameters["holdType"] = holdType
            parameters["offset"] = offset
            parameters["limit"] = limit
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.wallet.rawValue,
                     methodName:        "getTransferHistory",
                     parameters:        parameters)
            
        case .getBalance(let userId):
            var parameters = [String: Encodable]()
            parameters["userId"] = userId
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.wallet.rawValue,
                     methodName:        "getBalance",
                     parameters:        parameters)
            
        case .getBuyPrice(let pointSymbol, let quantity):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.wallet.rawValue,
                     methodName:        "getBuyPrice",
                     parameters:        ["pointSymbol": pointSymbol, "quantity": quantity])
            
        case .getSellPrice(let quantity):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.wallet.rawValue,
                     methodName:        "getSellPrice",
                     parameters:        ["quantity": quantity])
            
        case .getCurrenciesFull:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.exchange.rawValue,
                     methodName:        "getCurrenciesFull",
                     parameters:        [:])
            
        /// DEVICE
        case .deviceSetInfo(let timeZoneOffset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.device.rawValue,
                     methodName:        "setInfo",
                     parameters:        ["timeZoneOffset": timeZoneOffset])
            
        case .deviceSetFcmToken(let token):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.device.rawValue,
                     methodName:        "setFcmToken",
                     parameters:        ["fcmToken": token])
            
        case .deviceResetFcmToken:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.device.rawValue,
                     methodName:        "resetFcmToken",
                     parameters:        [:])
            
        case .getMinMaxAmount(let from, let to):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.exchange.rawValue,
                     methodName:        "getMinMaxAmount",
                     parameters:        ["from": from, "to": to])
            
        case .getExchangeAmount(let from, let to, let amount):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.exchange.rawValue,
                     methodName:        "getExchangeAmount",
                     parameters:        ["from": from, "to": to, "amount": amount])
            
        case .createTransaction(let from, let address, let amount, let extraId, let refundAddress, let refundExtraId):
            var parameters = [String: Encodable]()
            parameters["from"] = from
            parameters["address"] = address
            parameters["amount"] = amount
            parameters["extraId"] = extraId
            parameters["refundAddress"] = refundAddress
            parameters["refundExtraId"] = refundExtraId
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.exchange.rawValue,
                     methodName:        "createTransaction",
                     parameters:        parameters)
            
        /// REWARDS
        case .rewardsGetStateBulk(let posts):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.rewards.rawValue,
                     methodName:        "getStateBulk",
                     parameters:        ["posts": posts])
            
        /// DONATIONS
        case .getDonationsBulk(let posts):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.wallet.rawValue,
                     methodName:        "getDonationsBulk",
                     parameters:        ["posts": posts])
            
        /// SEARCH
        case .quickSearch(let queryString, let entities, let limit):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "quickSearch",
                     parameters:        ["queryString": queryString, "entities": entities, "limit": limit])
            
        case .extendedSearch(let queryString, let entities):
            var modifiedEntity = [String: [String: UInt]]()
            
            for (key, value) in entities {
                modifiedEntity[key.rawValue] = value
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "extendedSearch",
                     parameters:        ["queryString": queryString, "entities": modifiedEntity])
            
        case .entitySearch(let queryString, let entity, let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "entitySearch",
                     parameters:        ["queryString": queryString, "entity": entity, "limit": limit, "offset": offset])
            
        case .getUserSettings:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.settings.rawValue,
                     methodName:        "getUserSettings",
                     parameters:        [:])
            
        case .getAirdrop(let id):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.airdrop.rawValue,
                     methodName:        "getAirdrop",
                     parameters:        ["communityId": id])
            
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
            
        case .getProposals(let communityIds, let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getProposals",
                     parameters:        ["communityIds": communityIds, "limit": limit, "offset": offset ])
            
        case .getReportsList(let communityIds, let contentType, let status, let sortBy, let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getReportsList",
                     parameters:        ["communityIds": communityIds, "contentType": contentType, "status": status, "sortBy": sortBy.rawValue, "limit": limit, "offset": offset ])
            
        case .getEntityReports(let userId, let communityId, let permlink, let limit, let offset):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getEntityReports",
                     parameters:        ["userId": userId, "communityId": communityId, "permlink": permlink, "limit": limit, "offset": offset ])
            
        case .createNewCommunity(let name):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.community.rawValue,
                     methodName:        "createNewCommunity",
                     parameters:        ["name": name])
            
        case .communitySetSettings(let name, let avatarUrl, let coverUrl, let language, let description, let rules, let subject, let communityId):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.community.rawValue,
                     methodName:        "setSettings",
                     parameters:        ["name": name, "avatarUrl": avatarUrl, "coverUrl": coverUrl, "language": language, "description": description, "rules": rules, "subject": subject, "communityId": communityId])
            
        case .startCommunityCreation(let communityId, let transferTrxId):
            var parameters: [String: Encodable] = ["communityId": communityId]
            parameters["transferTrxId"] = transferTrxId
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.community.rawValue,
                     methodName:        "startCommunityCreation",
                     parameters:        parameters)
            
        case .getUsersCommunity:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.community.rawValue,
                     methodName:        "getUsersCommunities",
                     parameters:        [:])
            
        } // switch
    }
}

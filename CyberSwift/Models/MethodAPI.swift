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

/// Type of request parameters
typealias RequestMethodParameters   =   (methodAPIType: MethodAPIType, methodGroup: String, methodName: String, parameters: [String: String])

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

public enum ProfileType: String {
    case golos              =   "gls"
    case cyber              =   "cyber"
}


public indirect enum MethodAPIType {
    /// FACADE-SERVICE
    //  Getting a user profile
    case getProfile(nickName: String, type: ProfileType)
    
    //  Getting tape posts
    case getFeed(typeMode: FeedTypeMode, userID: String?, communityID: String?, timeFrameMode: FeedTimeFrameMode, sortMode: FeedSortMode, paginationSequenceKey: String?)
    
    //  Getting selected post
    case getPost(userID: String, permlink: String)
    
    //  Getting user comments feed
    case getUserComments(nickName: String, sortMode: CommentSortMode, paginationSequenceKey: String?)
    
    //  Getting post comments feed
    case getPostComments(userNickName: String, permlink: String, sortMode: CommentSortMode, paginationSequenceKey: String?)
    
    //  Log in
    case authorize(nickName: String, activeKey: String)
    
    //  Get the secret authorization to sign
    case generateSecret

//    //  Receiving the number of unread notifications
//    case getPushHistory(nickName: String)

    //  Receiving the number of unread notifications according to user settings
    case getPushHistoryFresh(profile: String)
    
    //  Receive user's notifications
    case getOnlineNotifyHistory(fromId: String?, paginationLimit: Int8, markAsViewed: Bool, freshOnly: Bool)
    
    //  Receive user's fresh notifications count
    case getOnlineNotifyHistoryFresh
    
    //  Request for user settings
    case getOptions
    
    //  Set Basic options
    case setBasicOptions(nsfw: String, language: String)
    
    //  Set Push/Notify options
    case setNotice(options: RequestParameterAPI.NoticeOptions, type: NoticeType)
    
    //  Mark specified notifications as read
    #warning("Not work version")
    case markAsRead(notifies: [String])

    //  Mark all notifications as viewed
    case notifyMarkAllAsViewed

    //  Record the fact of viewing the post
    case recordPostView(permlink: String)

    
    /// REGISTRATION-SERVICE
    //  Get current registration status for user
    case getState(nickName: String?, phone: String?)
    
    //  First step of registration
    case firstStep(phone: String, isDebugMode: Bool)
    
    //  Second registration step, account verification
    case verify(phone: String, code: String, isDebugMode: Bool)
    
    //  The third step of registration, account verification
    case setUser(name: String, phone: String, isDebugMode: Bool)
    
    //  Re-send of the confirmation code (for the smsToUser strategy)
    case resendSmsCode(phone: String, isDebugMode: Bool)
    
    //  The last step of registration, entry in the blockchain
    case toBlockChain(nickName: String, keys: [UserKeys])

    
    /// This method return request parameters from selected enum case.
    func introduced() -> RequestMethodParameters {
        switch self {
        /// FACADE-SERVICE
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "content.getProfile", "params": { "userId": "tst3uuqzetwf" }}
        case .getProfile(let nickNameValue, let typeValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getProfile",
                     parameters:        ["userId": nickNameValue, "type": typeValue.rawValue])
            
        //  Template { "id": 2, "jsonrpc": "2.0", "method": "content.getFeed", "params": { "type": "community", "timeframe": "day", "sortBy": "popular", "limit": 20, "userId": "tst3uuqzetwf", "communityId": "gls" }}
        case .getFeed(let typeModeValue, let userNickNameValue, let communityIDValue, let timeFrameModeValue, let sortModeValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": typeModeValue.rawValue, "timeframe": timeFrameModeValue.rawValue, "sortBy": sortModeValue.rawValue, "limit": "\(Config.paginationLimit)"]
            
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
            
        //  Template { "id": 4, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "user", "userId": "tst2nbduouxh", "sortBy": "time", "limit": 20 }}
        case .getUserComments(let userNickNameValue, let sortModeValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": "user", "userId": userNickNameValue, "sortBy": sortModeValue.rawValue, "limit": "\(Config.paginationLimit)"]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        //  Template { "id": 5, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "post", "userId": "tst1xrhojmka", "sortBy": "time", "permlink":  "demeterfightswithandromedaagainstepimetheus", "refBlockNum": "520095", "limit": 20 }}
        case .getPostComments(let userNickNameValue, let permlinkValue, let sortModeValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": "post", "userId": userNickNameValue, "permlink": permlinkValue, "sortBy": sortModeValue.rawValue, "limit": "\(Config.paginationLimit)"]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        //  Template { "id": 6, "jsonrpc": "2.0", "method": "auth.authorize", "params": { "user": "tst1xrhojmka", "sign": "Cyberway" }}
        case .authorize(let nickNameValue, let activeKeyValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "authorize",
                     parameters:        ["user": nickNameValue, "secret": Config.webSocketSecretKey, "sign": EOSManager.signWebSocketSecretKey(userActiveKey: activeKeyValue) ?? "Cyberway"])
            
        //  Template { "id": 7, "jsonrpc": "2.0", "method": "auth.generateSecret", "params": { "": "" }}
        case .generateSecret:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "generateSecret",
                     parameters:        ["": ""])

        //  Template { "id": 8, "jsonrpc": "2.0", "method": "push.historyFresh", "params": { "": "" }}
        case .getPushHistoryFresh(let profileValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.push.rawValue,
                     methodName:        "historyFresh",
                     parameters:        ["profile": profileValue])
            
        //  Template { "id": 9, "jsonrpc": "2.0", "method": "onlineNotify.history", "params": { "freshOnly": true, "fromId": "3123", markAsViewed}}
        case .getOnlineNotifyHistory(let fromId, _, let markAsViewed, let freshOnly):
            var parameters: [String: String] = ["limit": "\(Config.paginationLimit)", "markAsViewed": markAsViewed.toParam, "freshOnly": freshOnly.toParam]
            
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
                     parameters:        ["profile": String(format: "%@-%@", Config.currentUser.nickName!, Config.currentDeviceType)])
            
        //  Template { "id": 12, "jsonrpc": "2.0", "method": "options.set", "params": { "profile": <userNickName-deviceUDID>, "basic": { "language": "ru", "nsfwContent": "Always alert" }}}
        case .setBasicOptions(let nsfw, let language):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.options.rawValue,
                     methodName:        "set",
                     parameters:        [
                                            "profile":  String(format: "%@-%@", Config.currentUser.nickName!, Config.currentDeviceType),
                                            "basic":    String(format: "{\"language\": \"%@\", \"nsfwContent\": \"%@\"}", language, nsfw)
                                        ])

        //  Template { "id": 13, "jsonrpc": "2.0", "method": "options.set", "params": { "profile": <userNickName-deviceUDID>, "push": { "lang": <languageValue>, "show": { "vote": <voteValue>, "flag": <flagValue>, "reply": <replyValue>, "transfer": <transferValue>, "subscribe": <subscribeValue>, "unsubscribe": <unsibscribeValue>, "mention": <mentionValue>, "repost": <repostValue>,  "message": <messageValue>, "witnessVote": <witnessVoteValue>, "witnessCancelVote": <witnessCancelVoteValue>, "reward": <rewardValue>, "curatorReward": <curatorRewardValue> }}}
        case .setNotice(let options, let type):
            var parameters: [String: String] = [ "profile":  String(format: "%@-%@", Config.currentUser.nickName!, Config.currentDeviceType) ]
            
            if type == .push {
                parameters["push"]      =   String(format: "{\"lang\": \"%@\", \"show\": {%@}}", "ru", options.getNoticeOptionsValues())
            }
            
            if type == .notify {
                parameters["notify"]    =   String(format: "{\"show\": {%@}}", options.getNoticeOptionsValues())
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
                     parameters:        ["ids": notifies.description])

        //  Template { "id": 15, "jsonrpc": "2.0", "method": "meta.recordPostView", "params": { "postLink": <author.permlink>, "fingerPrint": <deviceUDID> }}
        case .recordPostView(let permlink):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.meta.rawValue,
                     methodName:        "recordPostView",
                     parameters:        ["postLink": permlink, "fingerPrint": Config.currentDeviceType])
            
            
        /// REGISTRATION-SERVICE
        //  Template { "id": 1, "jsonrpc": "2.0", "method": "registration.getState", "params": { "phone": "+70000000000" }}
        case .getState(let nickNameValue, let phoneValue):
            var parameters = [String: String]()
                
            if nickNameValue != nil {
                parameters["user"] = nickNameValue!
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

        //  Debug template      { "id": 3, "jsonrpc": "2.0", "method": "registration.verify", "params": { "phone": "+70000000000", "code": "1563", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 3, "jsonrpc": "2.0", "method": "registration.verify", "params": { "phone": "+70000000000", "code": "1563" }}
        case .verify(let phoneValue, let codeValue, let isDebugMode):
            var parameters = ["phone": phoneValue, "code": codeValue]
            
            if isDebugMode {
                parameters["testingPass"] = Config.testingPassword
            }

            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "verify",
                     parameters:        parameters)
            
        //  Debug template      { "id": 4, "jsonrpc": "2.0", "method": "registration.setUsername", "params": { "user": "tester", "phone": "+70000000000", "testingPass": "DpQad16yDlllEy6" }}
        //  Release template    { "id": 4, "jsonrpc": "2.0", "method": "registration.setUsername", "params": { "user": "tester", "phone": "+70000000000" }}
        case .setUser(let nameValue, let phoneValue, let isDebugMode):
            var parameters = ["phone": phoneValue, "user": nameValue]
            
            if isDebugMode {
                parameters["testingPass"] = Config.testingPassword
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "setUsername",
                     parameters:        parameters)

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
        case .toBlockChain(let nickNameValue, let keysValues):
            var parameters = ["user": nickNameValue]

            if let ownerUserKey = keysValues.first(where: { $0.type == "owner" }) {
                parameters["owner"] = ownerUserKey.publicKey
            }

            if let activeUserKey = keysValues.first(where: { $0.type == "active" }) {
                parameters["active"] = activeUserKey.publicKey
            }

            if let postingUserKey = keysValues.first(where: { $0.type == "posting" }) {
                parameters["posting"] = postingUserKey.publicKey
            }

            if let memoUserKey = keysValues.first(where: { $0.type == "memo" }) {
                parameters["memo"] = memoUserKey.publicKey
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.registration.rawValue,
                     methodName:        "toBlockChain",
                     parameters:        parameters)
            
        } // switch
    }
}

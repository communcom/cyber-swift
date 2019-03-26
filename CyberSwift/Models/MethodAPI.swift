//
//  MethodAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//
//  This enum use for GET Requests
//
//  https://github.com/GolosChain/facade-service/tree/develop
//  https://github.com/GolosChain/api-documentation
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


public indirect enum MethodAPIType {
    /// Getting a user profile
    case getProfile(nickNames: String)
    
    /// Getting tape posts
    case getFeed(typeMode: FeedTypeMode, userID: String?, communityID: String?, timeFrameMode: FeedTimeFrameMode, sortMode: FeedSortMode, paginationLimit: Int8, paginationSequenceKey: String?)
    
    /// Getting selected post
    case getPost(userID: String, permlink: String, refBlockNum: UInt64)
    
    /// Getting user comments feed
    case getUserComments(nickName: String, sortMode: CommentSortMode, paginationLimit: Int8, paginationSequenceKey: String?)
    
    /// Getting post comments feed
    case getPostComments(userNickName: String, permlink: String, refBlockNum: UInt64, sortMode: CommentSortMode, paginationLimit: Int8, paginationSequenceKey: String?)
    
    /// Log in
    case authorize(nickName: String)
    
    /// Get the secret authorization to sign
    case generateSecret
    
    
    /// This method return request parameters from selected enum case.
    func introduced() -> RequestMethodParameters {
        switch self {
        /// Template { "id": 1, "jsonrpc": "2.0", "method": "content.getProfile", "params": { "userId": "tst3uuqzetwf" }}
        case .getProfile(let userNickNameValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getProfile",
                     parameters:        ["userId": userNickNameValue])
            
        /// Template { "id": 2, "jsonrpc": "2.0", "method": "content.getFeed", "params": { "type": "community", "timeframe": "day", "sortBy": "popular", "limit": 20, "userId": "tst3uuqzetwf", "communityId": "gls" }}
        case .getFeed(let typeModeValue, let userNickNameValue, let communityIDValue, let timeFrameModeValue, let sortModeValue, let paginationLimitValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": typeModeValue.rawValue, "timeframe": timeFrameModeValue.rawValue, "sortBy": sortModeValue.rawValue, "limit": "\(paginationLimitValue)"]
            
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
            
        /// Template { "id": 3, "jsonrpc": "2.0", "method": "content.getPost", "params": { "userId": "tst2nbduouxh", "permlink": "hephaestusfightswithantigoneagainststyx", "refBlockNum": 381607 }}
        case .getPost(let userNickNameValue, let permlinkValue, let refBlockNumValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getPost",
                     parameters:        ["userId": userNickNameValue, "permlink": permlinkValue, "refBlockNum": "\(refBlockNumValue)"])
            
        /// Template { "id": 4, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "user", "userId": "tst2nbduouxh", "sortBy": "time", "limit": "20" }}
        case .getUserComments(let userNickNameValue, let sortModeValue, let paginationLimitValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": "user", "userId": userNickNameValue, "sortBy": sortModeValue.rawValue, "limit": "\(paginationLimitValue)"]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        /// Template { "id": 5, "jsonrpc": "2.0", "method": "content.getComments", "params": { "type: "post", "userId": "tst1xrhojmka", "sortBy": "time", "permlink":  "demeterfightswithandromedaagainstepimetheus", "refBlockNum": "520095", "limit": "20" }}
        case .getPostComments(let userNickNameValue, let permlinkValue, let refBlockNumValue, let sortModeValue, let paginationLimitValue, let paginationSequenceKeyValue):
            var parameters: [String: String] = ["type": "post", "userId": userNickNameValue, "permlink": permlinkValue, "refBlockNum": "\(refBlockNumValue)", "sortBy": sortModeValue.rawValue, "limit": "\(paginationLimitValue)"]
            
            if let paginationSequenceKeyValue = paginationSequenceKeyValue {
                parameters["sequenceKey"] = paginationSequenceKeyValue
            }
            
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.content.rawValue,
                     methodName:        "getComments",
                     parameters:        parameters)
            
        /// Template { "id": 6, "jsonrpc": "2.0", "method": "auth.authorize", "params": { "user": "tst1xrhojmka", "sign": "Cyberway" }}
        case .authorize(let nickNameValue):
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "authorize",
                     parameters:        ["user": nickNameValue, "secret": Config.webSocketSecretKey, "sign": EOSManager.signWebSocketSecretKey() ?? "Cyberway"])
            
        /// Template { "id": 7, "jsonrpc": "2.0", "method": "auth.generateSecret", "params": { "": "" }}
        case .generateSecret:
            return  (methodAPIType:     self,
                     methodGroup:       MethodAPIGroup.auth.rawValue,
                     methodName:        "generateSecret",
                     parameters:        ["": ""])
            
        } // switch
    }
}

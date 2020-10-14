//
//  RAM+Profile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    // API `content.resolveProfile`
    public func resolveProfile(username: String) -> Single<ResponseAPIContentGetProfile> {
        executeGetRequest(methodGroup: .content, methodName: "resolveProfile", params: ["username": username], authorizationRequired: false)
    }
    
    // API `content.getProfile`
    public func getProfile(
        user: String? = nil,
        appProfileType: AppProfileType = .cyber,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetProfile> {
        if user == nil {
            return .error(CMError.invalidRequest(message: ErrorMessage.userIdOrUsernameIsMissing.rawValue))
        }
        
        var params = [String: Encodable]()
        params["user"] = user
        params["userId"] = Config.currentUser?.id
        
        return executeGetRequest(methodGroup: .content, methodName: "getProfile", params: params)
    }
    
    // API `content.getComments` by user
    public func loadUserComments(
        sortBy: CommentSortMode = .time,
        offset: UInt            = 0,
        limit: UInt             = UInt(Config.paginationLimit),
        userId: String?,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetComments> {
        let parameters: [String: Encodable] =
            [
                "type": "user",
                "sortBy": sortBy.rawValue,
                "offset": offset,
                "limit": limit,
                "userId": userId,
                "resolveNestedComments": false
            ]
        return executeGetRequest(methodGroup: .content, methodName: "getComments", params: parameters, authorizationRequired: authorizationRequired)
    }
    
    // MARK: - Subscribers
    public func getSubscribers(
        userId: String?         = Config.currentUser?.id,
        communityId: String?    = nil,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscribers> {
        var params: [String: Encodable] = [
            "offset": offset,
            "limit": limit
        ]
        
        if let communityId = communityId {
            params["communityId"]   = communityId
        } else {
            params["userId"]        = userId
        }
        
        return executeGetRequest(methodGroup: .content, methodName: "getSubscribers", params: params)
    }
    
    // MARK: - Subscriptions
    public func getSubscriptions(
        userId: String?         = Config.currentUser?.id,
        type: GetSubscriptionsType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscriptions> {
        let params: [String: Encodable] = [
            "offset": offset,
            "limit": limit,
            "type": type.rawValue,
            "userId": userId
        ]
        
        return executeGetRequest(methodGroup: .content, methodName: "getSubscriptions", params: params)
    }
    
    // MARK: - Blacklist
    public func getBlacklist(
        userId: String?         = Config.currentUser?.id,
        type: GetBlacklistType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetBlacklist> {
        executeGetRequest(methodGroup: .content, methodName: "getBlacklist", params: ["userId": userId, "type": type.rawValue/*, "limit": limit, "offset": offset*/])
    }
}

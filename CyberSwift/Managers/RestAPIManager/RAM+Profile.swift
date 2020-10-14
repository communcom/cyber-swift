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
    
    // API basic `options.set`
    public func setBasicOptions(nsfwContent: NsfwContentMode) -> Single<ResponseAPIStatus> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(CMError.unauthorized())}

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue)
        
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Subscribers
    public func getSubscribers(
        userId: String?         = Config.currentUser?.id,
        communityId: String?    = nil,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscribers> {
        let methodAPIType = MethodAPIType.getSubscribers(userId: userId, communityId: communityId, offset: offset, limit: limit)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Subscriptions
    public func getSubscriptions(
        userId: String?         = Config.currentUser?.id,
        type: GetSubscriptionsType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscriptions> {
        let methodAPIType = MethodAPIType.getSubscriptions(userId: userId, type: type, offset: offset, limit: limit)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Blacklist
    public func getBlacklist(
        userId: String?         = Config.currentUser?.id,
        type: GetBlacklistType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetBlacklist> {
        let methodAPIType = MethodAPIType.getBlacklist(userId: userId, type: type, limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

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
        let methodAPIType = MethodAPIType.resolveProfile(username: username)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false)
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
        
        let methodAPIType = MethodAPIType.getProfile(user: user)

        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
            .do(onSuccess: { (profile) in
                if profile.userId == Config.currentUser?.id,
                    let urlString = profile.avatarUrl
                {
                    UserDefaults.standard.set(urlString, forKey: Config.currentUserAvatarUrlKey)
                }
            })
    }
    
    // API `content.getComments` by user
    public func loadUserComments(
        sortBy: CommentSortMode = .time,
        offset: UInt            = 0,
        limit: UInt             = UInt(Config.paginationLimit),
        userId: String?,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetComments> {
        guard let userId = userId ?? Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }
        
        let methodAPIType = MethodAPIType.getComments(
            sortBy: sortBy,
            offset: offset,
            limit: limit,
            type: .user,
            userId: userId,
            permlink: nil,
            communityId: nil,
            communityAlias: nil,
            parentComment: nil,
            resolveNestedComments: false)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
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
        limit: Int              = 10,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetSubscriptions> {
        let methodAPIType = MethodAPIType.getSubscriptions(userId: userId, type: type, offset: offset, limit: limit)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
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

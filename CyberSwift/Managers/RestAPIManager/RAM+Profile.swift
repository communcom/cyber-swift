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
    public func resolveProfile(username: String) -> Single<ResponseAPIContentResolveProfile> {
        let methodAPIType = MethodAPIType.resolveProfile(username: username)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `content.getProfile`
    public func getProfile(
        user: String? = nil,
        appProfileType: AppProfileType = .cyber
    ) -> Single<ResponseAPIContentGetProfile> {
        
        if user == nil {
            return .error(ErrorAPI.requestFailed(message: "userID or username is missing"))
        }
        
        let methodAPIType = MethodAPIType.getProfile(user: user)

        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `content.getComments` by user
    public func loadUserComments(
        sortBy: CommentSortMode = .time,
        offset: UInt            = 0,
        limit: UInt             = UInt(Config.paginationLimit),
        userId: String?
    ) -> Single<ResponseAPIContentGetComments> {
        guard let userId = userId ?? Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
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
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API basic `options.set`
    public func setBasicOptions(nsfwContent: NsfwContentMode) -> Single<ResponseAPIStatus> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.setBasicOptions(nsfw: nsfwContent.rawValue)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `favorites.get`
    public func getFavorites() -> Single<ResponseAPIGetFavorites> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.getFavorites
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }

    // API `favorites.add`
    public func addFavorites(permlink: String) -> Single<ResponseAPIStatus> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}

        let methodAPIType = MethodAPIType.addFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }

    // API `favorites.remove`
    public func removeFavorites(permlink: String) -> Single<ResponseAPIStatus> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(ErrorAPI.unauthorized)}
        
        let methodAPIType = MethodAPIType.removeFavorites(permlink: permlink)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Subscribers
    public func getSubscribers(
        userId: String?         = Config.currentUser?.id,
        communityId: String?    = nil,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscribers> {
        let methodAPIType = MethodAPIType.getSubscribers(userId: userId, communityId: communityId, offset: offset, limit: limit)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Subscriptions
    public func getSubscriptions(
        userId: String?         = Config.currentUser?.id,
        type: GetSubscriptionsType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetSubscriptions> {
        let methodAPIType = MethodAPIType.getSubscriptions(userId: userId, type: type, offset: offset, limit: limit)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Blacklist
    public func getBlacklist(
        userId: String?         = Config.currentUser?.id,
        type: GetBlacklistType,
        offset: Int             = 0,
        limit: Int              = 10
    ) -> Single<ResponseAPIContentGetBlacklist> {
        let methodAPIType = MethodAPIType.getBlacklist(userId: userId, type: type, limit: limit, offset: offset)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

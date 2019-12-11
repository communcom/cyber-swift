//
//  ResponseAPIContentProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// MARK: - QrCode
public struct QrCodeDecodedProfile: Decodable {
    public let userId: String?
    public let username: String
    public let password: String
}

// MARK: - API `content.resolveProfile`
public struct ResponseAPIContentResolveProfile: Encodable, ListItemType {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var isSubscribed: Bool?
    public var subscribersCount: UInt64?
    public var postsCount: UInt64?
    
    // additional property
    public var isBeingToggledFollow: Bool? = false
    
    public var identity: String {
        return userId + "/" + username
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentResolveProfile) -> ResponseAPIContentResolveProfile? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentResolveProfile(
            userId: item.userId,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            subscribersCount: item.subscribersCount ?? self.subscribersCount,
            postsCount: item.postsCount ?? self.postsCount,
            isBeingToggledFollow: item.isBeingToggledFollow ?? self.isBeingToggledFollow
        )
    }
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: ListItemType {
    public let stats: ResponseAPIContentGetProfileStat
    public let leaderIn: [String]?
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public let coverUrl: String?
    public let registration: ResponseAPIContentGetProfileRegistration
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public let personal: ResponseAPIContentGetProfilePersonal?
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public var isBlocked: Bool?
    public var highlightCommunitiesCount: UInt64?
    public var highlightCommunities: [ResponseAPIContentGetCommunity]
    
    // Additional properties
    public var isBeingToggledFollow: Bool? = false
    
    public var identity: String {
        return userId + "/" + username
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetProfile) -> ResponseAPIContentGetProfile? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetProfile(
            stats: item.stats,
            leaderIn: item.leaderIn ?? self.leaderIn,
            userId: item.userId,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            coverUrl: item.coverUrl ?? self.coverUrl,
            registration: item.registration,
            subscribers: item.subscribers ?? self.subscribers,
            subscriptions: item.subscriptions ?? self.subscriptions,
            personal: item.personal ?? self.personal,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            isSubscription: item.isSubscription ?? self.isSubscription,
            isBlocked: item.isBlocked ?? self.isBlocked,
            highlightCommunitiesCount: item.highlightCommunitiesCount ?? self.highlightCommunitiesCount,
            highlightCommunities: item.highlightCommunities,
            isBeingToggledFollow: item.isBeingToggledFollow ?? self.isBeingToggledFollow
        )
    }
}

public struct ResponseAPIContentGetProfileSubscription: Decodable, Equatable {
    public var usersCount: UInt64?
    public var communitiesCount: UInt64?
}

public struct ResponseAPIContentGetProfileRegistration: Decodable, Equatable {
    public let time: String
}

public struct ResponseAPIContentGetProfileStat: Decodable, Equatable {
    public let reputation: Int64
    public let postsCount: Int64
    public let commentsCount: Int64
}

public struct ResponseAPIContentGetProfilePersonal: Decodable, Equatable {
    public let contacts: ResponseAPIContentGetProfileContact?
    public let biography: String?
}

public struct ResponseAPIContentGetProfileSubscriber: Decodable, Equatable {
    public var usersCount: UInt64?
    public let communitiesCount: UInt64?
}

public struct ResponseAPIContentGetProfileBlacklist: Decodable {
    public var userIds: [String]
    public var communityIds: [String]
}

public struct ResponseAPIContentGetProfileContact: Decodable, Equatable {
    public let facebook: String?
    public let telegram: String?
    public let whatsApp: String?
    public let weChat: String?
}

public struct ResponseAPIContentGetProfileSubscribers: Decodable {
    public let usersCount: UInt64
    public let communitiesCount: UInt64
}

// MARK: - API `content.getSubscribers`
public struct ResponseAPIContentGetSubscribers: Decodable {
    public let items: [ResponseAPIContentResolveProfile]
}

// MARK: - API `content.getSubscriptions`
public struct ResponseAPIContentGetSubscriptions: Decodable {
    public let items: [ResponseAPIContentGetSubscriptionsItem]
}

public enum ResponseAPIContentGetSubscriptionsItem: ListItemType {
    public static func == (lhs: ResponseAPIContentGetSubscriptionsItem, rhs: ResponseAPIContentGetSubscriptionsItem) -> Bool {
        switch (lhs, rhs) {
        case (.user(let user), .user(let user2)):
            return user == user2
        case (.community(let com1), .community(let com2)):
            return com1 == com2
        default:
            return false
        }
    }
    
    case user(ResponseAPIContentGetSubscriptionsUser)
    case community(ResponseAPIContentGetCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetSubscriptionsUser.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetCommunity.self) {
            self = .community(communities)
            return
        }
        throw ErrorAPI.unsupported
    }
    
    public var userValue: ResponseAPIContentGetSubscriptionsUser? {
        switch self {
        case .user(let user):
            return user
        default:
            return nil
        }
    }
    
    public var communityValue: ResponseAPIContentGetCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
    
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetSubscriptionsItem) -> ResponseAPIContentGetSubscriptionsItem? {
        guard item.identity == self.identity else {return nil}
        switch self {
        case .user(let userSelf):
            guard let newUser = item.userValue else {return nil}
            guard let updatedUser = userSelf.newUpdatedItem(from: newUser) else {return nil}
            return ResponseAPIContentGetSubscriptionsItem.user(updatedUser)
        case .community(let communitySelf):
            guard let newCommunity = item.communityValue else {return nil}
            guard let updatedCommunity = communitySelf.newUpdatedItem(from: newCommunity) else {return nil}
            return ResponseAPIContentGetSubscriptionsItem.community(updatedCommunity)
        }
    }
}

public struct ResponseAPIContentGetSubscriptionsUser: ListItemType {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var subscribersCount: UInt64?
    public let postsCount: UInt64?
    public var isSubscribed: Bool?
    
    // additional property
    public var isBeingToggledFollow: Bool? = false
    
    public var identity: String {
        return userId + "/" + username
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetSubscriptionsUser) -> ResponseAPIContentGetSubscriptionsUser? {
        guard item.identity == self.identity else {return nil}
        
        return ResponseAPIContentGetSubscriptionsUser(
            userId: item.userId,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            subscribersCount: item.subscribersCount ?? self.subscribersCount,
            postsCount: item.postsCount ?? self.postsCount,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            isBeingToggledFollow: item.isBeingToggledFollow ?? self.isBeingToggledFollow
        )
    }
}

// MARK: - API `content.getBlacklist`
public struct ResponseAPIContentGetBlacklist: Decodable {
    public let items: [ResponseAPIContentGetBlacklistItem]
}

public enum ResponseAPIContentGetBlacklistItem: ListItemType {
    public static func == (lhs: ResponseAPIContentGetBlacklistItem, rhs: ResponseAPIContentGetBlacklistItem) -> Bool {
        switch (lhs, rhs) {
        case (.user(let user), .user(let user2)):
            return user == user2
        case (.community(let com1), .community(let com2)):
            return com1 == com2
        default:
            return false
        }
    }
    case user(ResponseAPIContentGetBlacklistUser)
    case community(ResponseAPIContentGetBlacklistCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetBlacklistUser.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetBlacklistCommunity.self) {
            self = .community(communities)
            return
        }
        throw ErrorAPI.unsupported
    }
    
    public var userValue: ResponseAPIContentGetBlacklistUser? {
        switch self {
        case .user(let user):
            return user
        default:
            return nil
        }
    }
    
    public var communityValue: ResponseAPIContentGetBlacklistCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
    
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetBlacklistItem) -> ResponseAPIContentGetBlacklistItem? {
        guard item.identity == self.identity else {return nil}
        switch self {
        case .user(let userSelf):
            guard let newUser = item.userValue else {return nil}
            guard let updatedUser = userSelf.newUpdatedItem(from: newUser) else {return nil}
            return ResponseAPIContentGetBlacklistItem.user(updatedUser)
        case .community(let communitySelf):
            guard let newCommunity = item.communityValue else {return nil}
            guard let updatedCommunity = communitySelf.newUpdatedItem(from: newCommunity) else {return nil}
            return ResponseAPIContentGetBlacklistItem.community(updatedCommunity)
        }
    }
}

public struct ResponseAPIContentGetBlacklistUser: ListItemType {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var isSubscribed: Bool?
    
    // additional properties
    public var isBeingUnblocked: Bool? = false
    public var isBlocked: Bool? = true
    
    public var identity: String {
        return userId + "/" + username
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetBlacklistUser) -> ResponseAPIContentGetBlacklistUser? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetBlacklistUser(
            userId: item.userId,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            isBeingUnblocked: item.isBeingUnblocked ?? self.isBeingUnblocked,
            isBlocked: item.isBlocked ?? self.isBlocked
        )
    }
}

public struct ResponseAPIContentGetBlacklistCommunity: ListItemType {
    public let communityId: String
    public let alias: String?
    public let name: String
    public var isSubscribed: Bool?
    
    // additional properties
    public var isBeingUnblocked: Bool? = false
    public var isBlocked: Bool? = true
    
    public var identity: String {
        return communityId + "/" + name
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetBlacklistCommunity) -> ResponseAPIContentGetBlacklistCommunity? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetBlacklistCommunity(
            communityId: item.communityId,
            alias: item.alias ?? self.alias,
            name: item.name,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            isBeingUnblocked: item.isBeingUnblocked ?? self.isBeingUnblocked,
            isBlocked: item.isBlocked ?? self.isBlocked
        )
    }
}

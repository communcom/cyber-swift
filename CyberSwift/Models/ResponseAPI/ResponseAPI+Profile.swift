//
//  ResponseAPIContentProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

// MARK: - QrCode
public struct QrCodeDecodedProfile: Decodable {
    public let userId: String?
    public let username: String
    public let password: String
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: Encodable, ListItemType {
    public let stats: ResponseAPIContentGetProfileStat?
    public let leaderIn: [String]?
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public let coverUrl: String?
    public let registration: ResponseAPIContentGetProfileRegistration?
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public let personal: ResponseAPIContentGetProfilePersonal?
    public var isInBlacklist: Bool?
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public var isBlocked: Bool?
    public var highlightCommunitiesCount: Int64?
    public var highlightCommunities: [ResponseAPIContentGetCommunity]?
    
    // content.resolveProfile
    public var postsCount: Int64?
    public var subscribersCount: Int64?
    
    // Additional properties
    public var isBeingToggledFollow: Bool? = false
    public var isBeingUnblocked: Bool? = false
    
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

public struct ResponseAPIContentGetProfileSubscription: Codable, Equatable {
    public var usersCount: Int64?
    public var communitiesCount: Int64?
}

public struct ResponseAPIContentGetProfileRegistration: Codable, Equatable {
    public let time: String
}

public struct ResponseAPIContentGetProfileStat: Codable, Equatable {
    public let reputation: Int64
    public let postsCount: Int64
    public let commentsCount: Int64
}

public struct ResponseAPIContentGetProfilePersonal: Codable, Equatable {
    public let contacts: ResponseAPIContentGetProfileContact?
    public let biography: String?
}

public struct ResponseAPIContentGetProfileSubscriber: Codable, Equatable {
    public var usersCount: Int64?
    public let communitiesCount: Int64?
}

public struct ResponseAPIContentGetProfileBlacklist: Decodable {
    public var userIds: [String]
    public var communityIds: [String]
}

public struct ResponseAPIContentGetProfileContact: Codable, Equatable {
    public let facebook: String?
    public let telegram: String?
    public let whatsApp: String?
    public let weChat: String?
}

public struct ResponseAPIContentGetProfileSubscribers: Decodable {
    public let usersCount: Int64
    public let communitiesCount: Int64
}

// MARK: - API `content.getSubscribers`
public struct ResponseAPIContentGetSubscribers: Decodable {
    public let items: [ResponseAPIContentGetProfile]
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
    public var subscribersCount: Int64?
    public let postsCount: Int64?
    public var isSubscribed: Bool?
    public var isInBlacklist: Bool?
    
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
    case user(ResponseAPIContentGetProfile)
    case community(ResponseAPIContentGetCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetProfile.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetCommunity.self) {
            self = .community(communities)
            return
        }
        throw ErrorAPI.unsupported
    }
    
    public var userValue: ResponseAPIContentGetProfile? {
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

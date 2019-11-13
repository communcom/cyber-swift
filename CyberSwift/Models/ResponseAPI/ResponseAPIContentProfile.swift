//
//  ResponseAPIContentProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// MARK: - API `content.resolveProfile`
public struct ResponseAPIContentResolveProfile: Decodable, Equatable {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var isSubscribed: Bool?
    public var subscribersCount: UInt64?
    public var postsCount: UInt64?
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: Decodable, Equatable {
    public let stats: ResponseAPIContentGetProfileStat
    public let leaderIn: [String]?
    public let userId: String
    public let username: String
    public let registration: ResponseAPIContentGetProfileRegistration
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public let personal: ResponseAPIContentGetProfilePersonal?
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public var isBlocked: Bool?
    public var commonCommunitiesCount: UInt64?
    public var commonCommunities: [ResponseAPIContentGetProfileCommonCommunity]
}

public struct ResponseAPIContentGetProfileSubscription: Decodable, Equatable {
    public var usersCount: UInt64?
    public var communitiesCount: UInt64?
}

public struct ResponseAPIContentGetProfileCommonCommunity: Decodable, Equatable {
    public let communityId: String
    public let name: String
    public let alias: String?
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
    public let avatarUrl: String?
    public let coverUrl: String?
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

public enum ResponseAPIContentGetSubscriptionsItem: Decodable, Equatable {
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
    case community(ResponseAPIContentGetSubscriptionsCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetSubscriptionsUser.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetSubscriptionsCommunity.self) {
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
    
    public var communityValue: ResponseAPIContentGetSubscriptionsCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
}

public struct ResponseAPIContentGetSubscriptionsUser: Decodable, Equatable {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var subscribersCount: UInt64?
    public let postsCount: UInt64?
    public var isSubscribed: Bool?
}

public struct ResponseAPIContentGetSubscriptionsCommunity: Decodable, Equatable {
    public let communityId: String
    public let name: String
    public let code: String?
    public var isSubscribed: Bool?
    public let avatarUrl: String?
    public let coverUrl: String?
}

// MARK: - API `content.getBlacklist`
public typealias ResponseAPIContentGetBlacklist = ResponseAPIContentGetSubscriptions
public typealias ResponseAPIContentGetBlacklistItem = ResponseAPIContentGetSubscriptionsItem

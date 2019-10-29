//
//  ResponseAPIContentProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// MARK: - API `content.resolveProfile`
public struct ResponseAPIContentResolveProfile: Decodable {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public var isSubscribed: Bool?
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: Decodable {
    public let stats: ResponseAPIContentGetProfileStat
    public let leaderIn: [String]?
    public let userId: String
    public let username: String?
    public let registration: ResponseAPIContentGetProfileRegistration
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public let personal: ResponseAPIContentGetProfilePersonal
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public var isBlocked: Bool?
    public var commonCommunitiesCount: UInt64?
    public var commonCommunities: [ResponseAPIContentGetProfileCommonCommunity]
}

public struct ResponseAPIContentGetProfileSubscription: Decodable {
    public var usersCount: UInt64?
    public var communitiesCount: UInt64?
}

public struct ResponseAPIContentGetProfileCommonCommunity: Decodable {
    public let communityId: String
    public let name: String
    public let alias: String?
}

public struct ResponseAPIContentGetProfileRegistration: Decodable {
    public let time: String
}

public struct ResponseAPIContentGetProfileStat: Decodable {
    public let reputation: Int64
    public let postsCount: Int64
    public let commentsCount: Int64
}

public struct ResponseAPIContentGetProfilePersonal: Decodable {
    public let contacts: ResponseAPIContentGetProfileContact?
    public let avatarUrl: String?
    public let coverUrl: String?
    public let biography: String?
}

public struct ResponseAPIContentGetProfileSubscriber: Decodable {
    public var usersCount: UInt64?
    public let communitiesCount: UInt64?
}

public struct ResponseAPIContentGetProfileBlacklist: Decodable {
    public var userIds: [String]
    public var communityIds: [String]
}

public struct ResponseAPIContentGetProfileContact: Decodable {
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

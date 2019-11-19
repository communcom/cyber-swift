//
//  ResponseAPIContentCommunity.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// MARK: - API `content.getCommunities`
public struct ResponseAPIContentGetCommunities: Decodable {
    public let items: [ResponseAPIContentGetCommunity]
}

// MARK: - API `content.getCommunity`
public struct ResponseAPIContentGetCommunity: Decodable, Equatable {
    public var subscribersCount: UInt64?
    public var leadersCount: UInt64?
    public let postsCount: UInt64?
    public let communityId: String
    public let issuer: String?
    public let alias: String?
    public let rules: [ResponseAPIContentGetCommunityRule]?
    public let name: String
    public let registrationTime: String
    public let avatarUrl: String?
    public let coverUrl: String?
    public let description: String?
    public let language: String?
    public var isSubscribed: Bool?
    public let isBlocked: Bool?
    public let friendsCount: UInt64?
    public let friends: [ResponseAPIContentResolveProfile]?
    public var isLeader: Bool?
    public var isStoppedLeader: Bool?
    
    // Additional field
    public var isBeingJoined: Bool? = false
}

public struct ResponseAPIContentGetCommunityRule: Decodable, Equatable {
    public let id: String?
    public let title: String?
    public let text: String?
}

// MARK: - API `content.getLeaders`
public struct ResponseAPIContentGetLeaders: Decodable {
    public let items: [ResponseAPIContentGetLeader]
}

public struct ResponseAPIContentGetLeader: Decodable, Equatable {
    public let url: String
    public let rating: Double
    public let isActive: Bool
    public let userId: String
    public let position: UInt64
    public var isVoted: Bool
    public let ratingPercent: Double
    public let isSubscribed: Bool
    public let username: String?
    public let avatarUrl: String?
    
    // Additional property
    public var communityId: String?
    public var isBeingVoted: Bool? = false
}


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
    public let communities: [ResponseAPIContentGetCommunity]
}

// MARK: - API `content.getCommunity`
public struct ResponseAPIContentGetCommunity: Decodable, Equatable {
    public var subscribersCount: UInt64?
    public let communityId: String
    public let alias: String?
    public let name: String
    public let avatarUrl: String?
    public let coverUrl: String?
    public let description: String?
    public let language: String?
    public let rules: [ResponseAPIContentGetCommunityRule]?
    public var isSubscribed: Bool?
    public let isBlocked: Bool?
    public let friendsCount: UInt64?
    public let friends: [ResponseAPIContentResolveProfile]?
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

public struct ResponseAPIContentGetLeader: Decodable {
    public let url: String
    public let rating: UInt
    public let isActive: Bool
    public let userId: String
    public let position: UInt64
    public var isVoted: Bool
    public let ratingPercent: Double
    public let isSubscribed: Bool
    public let username: String?
    public let avatarUrl: String?
}


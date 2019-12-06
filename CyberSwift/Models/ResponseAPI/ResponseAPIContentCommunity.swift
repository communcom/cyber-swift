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
public struct ResponseAPIContentGetCommunity: Encodable, ListItemType {
    #warning("Be careful, mark new properties as optional, please!!!")
    
    public var subscribersCount: UInt64?
    public var leadersCount: UInt64?
    public let postsCount: UInt64?
    public let communityId: String
    public let name: String
    public let code: String?
    public var isSubscribed: Bool?
    public let avatarUrl: String?
    public let coverUrl: String?
    
    public let issuer: String?
    public let alias: String?
    public let rules: [ResponseAPIContentGetCommunityRule]?
    public let registrationTime: String?
    
    
    public let description: String?
    public let language: String?
    public let isBlocked: Bool?
    public let friendsCount: UInt64?
    public let friends: [ResponseAPIContentResolveProfile]?
    public var isLeader: Bool?
    public var isStoppedLeader: Bool?
    
    // Additional field
    public var isBeingJoined: Bool? = false
    
    public var identity: String {
        return communityId + "/" + name
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetCommunity) -> ResponseAPIContentGetCommunity? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetCommunity(
            subscribersCount: item.subscribersCount ?? self.subscribersCount,
            leadersCount: item.leadersCount ?? self.leadersCount,
            postsCount: item.postsCount ?? self.postsCount,
            communityId: item.communityId,
            name: item.name,
            code: item.code ?? self.code,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            coverUrl: item.coverUrl ?? self.coverUrl,
            issuer: item.issuer ?? self.issuer,
            alias: item.alias ?? self.alias,
            rules: item.rules ?? self.rules,
            registrationTime: item.registrationTime ?? self.registrationTime,
            description: item.description ?? self.description,
            language: item.language ?? self.language,
            isBlocked: item.isBlocked ?? self.isBlocked,
            friendsCount: item.friendsCount ?? self.friendsCount,
            friends: item.friends ?? self.friends,
            isLeader: item.isLeader ?? self.isLeader,
            isStoppedLeader: item.isStoppedLeader ?? self.isStoppedLeader,
            isBeingJoined: item.isBeingJoined ?? self.isBeingJoined
        )
    }
}

public struct ResponseAPIContentGetCommunityRule: Codable, Equatable {
    public let id: String?
    public let title: String?
    public let text: String?
    
    public var identity: String {
        return id ?? "\(Int.random(in: 0..<100))"
    }
}

// MARK: - API `content.getLeaders`
public struct ResponseAPIContentGetLeaders: Decodable {
    public let items: [ResponseAPIContentGetLeader]
}

public struct ResponseAPIContentGetLeader: ListItemType {
    public let url: String
    public let rating: Double
    public var votesCount: Int
    public let isActive: Bool
    public let userId: String
    public let position: UInt64
    public var isVoted: Bool?
    public let ratingPercent: Double
    public var isSubscribed: Bool?
    public let username: String
    public let avatarUrl: String?
    
    public var subscribersCount: UInt64?
    
    // Additional property
    public var communityId: String?
    public var isBeingVoted: Bool? = false
    public var isBeingToggledFollow: Bool? = false
    
    public var estimatedTableViewCellHeight: CGFloat? { return CGFloat.adaptive(height: 137.0) }
    public var tableViewCellHeight: CGFloat?
    
    public var identity: String {
        return userId
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetLeader) -> ResponseAPIContentGetLeader? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetLeader(
            url: item.url,
            rating: item.rating,
            votesCount: item.votesCount,
            isActive: item.isActive,
            userId: item.userId,
            position: item.position,
            isVoted: item.isVoted ?? self.isVoted,
            ratingPercent: item.ratingPercent,
            isSubscribed: item.isSubscribed,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            subscribersCount: item.subscribersCount ?? self.subscribersCount,
            communityId: item.communityId ?? self.communityId,
            isBeingVoted: item.isBeingVoted ?? self.isBeingVoted,
            isBeingToggledFollow: item.isBeingToggledFollow ?? self.isBeingToggledFollow
        )
    }
}

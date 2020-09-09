//
//  ResponseAPIContentCommunity.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

// MARK: - API `content.getCommunities`
public struct ResponseAPIContentGetCommunities: Decodable {
    public let items: [ResponseAPIContentGetCommunity]
}

// MARK: - API `content.getCommunity`
public struct ResponseAPIContentGetCommunity: Encodable, ListItemType {
    // FIXME: - Be careful, mark new properties as optional, please!!!
    public var subscribersCount: Int64?
    public var leadersCount: Int64?
    public let postsCount: Int64?
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
    public var isBlocked: Bool?
    public let friendsCount: Int64?
    public var friends: [ResponseAPIContentGetProfile]?
    public var isInBlacklist: Bool?
    public var isLeader: Bool?
    public var isStoppedLeader: Bool?
    
    // Create community
    public let currentStep: String?
    public let isDone: Bool?
    
    // Additional field
    public var isBeingJoined: Bool? = false
    public var isBeingUnblocked: Bool? = false
    
    public var identity: String {
        return communityId + "/" + name
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetCommunity) -> ResponseAPIContentGetCommunity? {
        guard item.identity == self.identity else {return nil}
        
        // modify community's member count
        var subscriberCount = max(item.subscribersCount ?? 0, self.subscribersCount ?? 0)
        if item.isSubscribed == false && isSubscribed == true {
            if item.subscribersCount == (subscribersCount ?? 0) - 1 {
                subscriberCount = item.subscribersCount ?? 0
            } else {
                subscriberCount -= 1
            }
        }
        
        if item.isSubscribed == true && isSubscribed == false {
            if item.subscribersCount == (subscribersCount ?? 0) + 1 {
                subscriberCount = item.subscribersCount ?? 0
            } else {
                subscriberCount += 1
            }
        }
        
        if subscriberCount < 0 {subscriberCount = 0}
        
        return ResponseAPIContentGetCommunity(
            subscribersCount: subscriberCount,
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
            isInBlacklist: item.isInBlacklist ?? self.isInBlacklist,
            isLeader: item.isLeader ?? self.isLeader,
            isStoppedLeader: item.isStoppedLeader ?? self.isStoppedLeader,
            currentStep: item.currentStep ?? self.currentStep,
            isDone: item.isDone ?? self.isDone,
            isBeingJoined: item.isBeingJoined ?? self.isBeingJoined,
            isBeingUnblocked: item.isBeingUnblocked ?? self.isBeingUnblocked
        )
    }
}

extension ResponseAPIContentGetCommunity {
    mutating func setIsSubscribed(_ value: Bool) {
        guard value != isSubscribed
        else {return}
        isSubscribed = value
        var subscribersCount: Int64 = (self.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0} else {
            if value == true {
                subscribersCount += 1
            } else {
                subscribersCount -= 1
            }
        }
        self.subscribersCount = subscribersCount
    }
}

public struct ResponseAPIContentGetCommunityRule: Encodable, ListItemType {
    public let id: String?
    public let title: String?
    public let text: String?
    public var isExpanded: Bool? = false
    
    public var identity: String {
        return "Rule#\(id ?? "\(Int.random(in: 0..<100))")"
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetCommunityRule) -> ResponseAPIContentGetCommunityRule? {
        ResponseAPIContentGetCommunityRule(id: item.id ?? id, title: item.title ?? title, text: item.text ?? text, isExpanded: item.isExpanded ?? isExpanded)
    }
}

// MARK: - API `content.getLeaders`
public struct ResponseAPIContentGetLeaders: Decodable {
    public let items: [ResponseAPIContentGetLeader]
}

public struct ResponseAPIContentGetLeader: ListItemType {
    public let url: String
    public let rating: Double
    public var votesCount: Int64
    public let isActive: Bool
    public let inTop: Bool
    public let userId: String
    public let position: Int64
    public var isVoted: Bool?
    public let ratingPercent: Double
    public var isSubscribed: Bool?
    public let username: String?
    public let avatarUrl: String?
    
    public var subscribersCount: Int64?
    public var isInBlacklist: Bool?
    
    // Additional property
    public var communityId: String?
    public var isBeingVoted: Bool? = false
    public var isBeingToggledFollow: Bool? = false
    
    public var estimatedTableViewCellHeight: CGFloat? { return .adaptive(height: 137.0) }
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
            inTop: item.inTop,
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

extension ResponseAPIContentGetLeader {
    mutating func setIsVoted(_ value: Bool) {
        guard value != isVoted else {return}
        isVoted = value
    }
}

// MARK: - API `community.createNewCommunity`
public struct ResponseAPICommunityCreateNewCommunity: Decodable {
    public let community: ResponseAPIContentGetCommunity
}

public struct ResponseAPIGetUserCommunities: Decodable {
    public let communities: [ResponseAPIContentGetCommunity]?
}

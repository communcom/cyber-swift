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
public struct ResponseAPIContentGetCommunity: Decodable {
    public var subscribersCount: UInt64?
    public let communityId: String?
    public let alias: String?
    public let name: String?
    public let avatarUrl: String?
    public let coverUrl: String?
    public let description: String?
    public let language: String?
    public let rules: String?
    public var isSubscribed: Bool?
    public let isBlocked: Bool?
    public let friendsCount: UInt64?
    public let friends: [ResponseAPIContentResolveProfile]?
}

// MARK: - API `content.getLeaders`
public struct ResponseAPIContentGetLeaders: Decodable {
    
}


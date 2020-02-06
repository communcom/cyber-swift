//
//  ResponseAPIContentResolveProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIContentGetProfile {
    public init(leader: ResponseAPIContentGetLeader) {
        self.stats = nil
        self.leaderIn = nil
        self.userId = leader.userId
        self.username = leader.username
        self.avatarUrl = leader.avatarUrl
        self.coverUrl = nil
        self.registration = nil
        self.subscribers = nil
        self.subscriptions = nil
        self.personal = nil
        self.isInBlacklist = leader.isInBlacklist
        self.isSubscribed = leader.isSubscribed
        self.isSubscription = nil
        self.isBlocked = nil
        self.highlightCommunities = nil
        self.highlightCommunitiesCount = nil
        
        self.subscribersCount = leader.subscribersCount
        self.postsCount = nil
        self.isBeingToggledFollow = leader.isBeingToggledFollow
    }
}

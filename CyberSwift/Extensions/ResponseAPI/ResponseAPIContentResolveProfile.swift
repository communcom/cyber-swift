//
//  ResponseAPIContentResolveProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIContentResolveProfile {
    public init(leader: ResponseAPIContentGetLeader) {
        self.userId = leader.userId
        self.username = leader.username
        self.avatarUrl = leader.avatarUrl
        self.isSubscribed = leader.isSubscribed
        self.subscribersCount = leader.subscribersCount
        self.postsCount = nil
        self.isBeingToggledFollow = leader.isBeingToggledFollow
    }
}

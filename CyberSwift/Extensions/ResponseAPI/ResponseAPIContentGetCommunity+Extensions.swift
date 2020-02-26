//
//  ResponseAPIContentGetCommunity.swift
//  CyberSwift
//
//  Created by Chung Tran on 2/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ResponseAPIContentGetCommunity {
    public static var followedEventName: String {"Followed"}
    public static var unfollowedEventName: String {"Unfollowed"}
    
    public static func observeCommunityFollowed() -> Observable<Self> {
        observeEvent(eventName: followedEventName)
    }
    
    public static func observeCommunityUnfollowed() -> Observable<Self> {
        observeEvent(eventName: unfollowedEventName)
    }
}

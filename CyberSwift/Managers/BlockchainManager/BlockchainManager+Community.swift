//
//  BlockchainManager+Community.swift
//  CyberSwift
//
//  Created by Chung Tran on 4/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension BlockchainManager {
    // MARK: - Follow
    public func triggerFollow(community: ResponseAPIContentGetCommunity) -> Completable {
        // for reverse
        let originIsFollowing = community.isSubscribed ?? false
        let originIsInBlacklist = community.isInBlacklist ?? false
        
        // set value
        var community = community
        community.setIsSubscribed(!originIsFollowing)
        community.isInBlacklist = false
        community.isBeingJoined = true
        
        // notify changes
        community.notifyChanged()
        
        let request: Single<String>
        
        if originIsInBlacklist {
            request = unhideCommunity(community.communityId)
                .flatMap {_ in self.followCommunity(community.communityId)}
        } else if originIsFollowing {
            request = unfollowCommunity(community.communityId)
        } else {
            request = followCommunity(community.communityId)
        }
        
        return request
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .do(onError: { (_) in
                // reverse change
                community.setIsSubscribed(originIsFollowing)
                community.isBeingJoined = false
                community.isInBlacklist = originIsInBlacklist
                community.notifyChanged()
            }, onCompleted: {
                // re-enable state
                community.isBeingJoined = false
                community.notifyChanged()
                
                if community.isSubscribed == false {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.unfollowedEventName)
                } else {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.followedEventName)
                }
            })
    }
    
    // MARK: - Hide
    public func hideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return unfollowCommunity(communityId)
            .flatMap {_ in EOSManager.hideCommunity(args)}
    }
    
    public func unhideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unhideCommunity(args)
    }
    
    // MARK: - Helpers
    private func followCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let followArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.followCommunity(followArgs)
    }
    
    private func unfollowCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let unFollowArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unfollowCommunity(unFollowArgs)
    }
}

//
//  BlockchainManager+Profile.swift
//  CyberSwift
//
//  Created by Chung Tran on 4/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension BlockchainManager {
    // MARK: - Update
    public func updateProfile(params: [String: String], waitForTransaction: Bool = true) -> Completable {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let userProfileAccountmetaArgs = EOSArgument.UserProfileAccountmetaArgs(json: params)

        let userProfileMetaArgs = EOSArgument.UpdateUser(accountValue: userID,
                                                                           metaValue: userProfileAccountmetaArgs)

        return EOSManager.update(userProfileMetaArgs: userProfileMetaArgs)
            .do(onSuccess: { _ in
                // update profile
                if let url = params["avatar_url"] {
                    UserDefaults.standard.set(url, forKey: Config.currentUserAvatarUrlKey)
                }
            })
            .flatMapCompletable({ (transaction) -> Completable in
                if !waitForTransaction {return .empty()}
                return RestAPIManager.instance.waitForTransactionWith(id: transaction)
            })
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: - Follow
    public func triggerFollow<T: ProfileType>(user: T) -> Completable {
        let originIsFollowing = user.isSubscribed ?? false
        let originIsInBlacklist = user.isInBlacklist ?? false
        
        // set value
        var user = user
        user.setIsSubscribed(!originIsFollowing)
        user.isInBlacklist = false
        user.isBeingToggledFollow = true
        
        // notify changes
        user.notifyChanged()
        
        // send request
        var request = follow(user.userId, isUnfollow: originIsFollowing)
        
        if originIsInBlacklist
        {
            request = unblock(user.userId)
                .flatMap {_ in self.follow(user.userId)}
        }
        
        return request
            .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
            .do(onError: { (_) in
                // reverse change
                user.setIsSubscribed(originIsFollowing)
                user.isBeingToggledFollow = false
                user.isInBlacklist = originIsInBlacklist
                user.notifyChanged()
            }, onCompleted: {
                // re-enable state
                user.isBeingToggledFollow = false
                user.notifyChanged()
                
                if user.isSubscribed == false {
                    user.notifyEvent(eventName: ResponseAPIContentGetProfile.unfollowedEventName)
                } else {
                    user.notifyEvent(eventName: ResponseAPIContentGetProfile.followedEventName)
                }
            })
    }
    
    // MARK: - Block
    public func block(_ userToBlock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToBlock)
        return follow(userToBlock, isUnfollow: true)
            .flatMap {_ in EOSManager.block(args: args)}
    }
    
    public func unblock(_ userToUnblock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToUnblock)
        return EOSManager.unblock(args: args)
    }
    
    // MARK: - Helpers
    private func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let pinArgs = EOSArgument.PinUser(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }
}

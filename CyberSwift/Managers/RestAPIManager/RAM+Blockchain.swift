//
//  RestAPIManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension RestAPIManager: ReactiveCompatible {}

public typealias SendPostCompletion = (transactionId: String?, userId: String?, permlink: String?)

extension Reactive where Base: RestAPIManager {
    //  MARK: - Contract `gls.publish`
    public func vote(voteType:       VoteActionType,
                     communityId:    String,
                     author:         String,
                     permlink:       String) -> Completable {
       
        
        return EOSManager.vote(voteType: voteType,
                               communityId: communityId,
                               author: author,
                               permlink: permlink)
    }

    public func create(
        communCode:         String,
        message:             String,
        headline:            String? = nil,
        parentPermlink:      String? = nil,
        parentAuthor:        String? = nil,
        tags:                [String]?
    ) -> Single<SendPostCompletion> {
        // Check for authorization
        guard let userId = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }

        // Prepare array
        let tags = tags ?? []
        
        // Construct message create Args
        
        let headermssgValue     =   headline ?? ""
        let prefixTitle         =   parentPermlink == nil ? headermssgValue : "Comment"
        let messagePermlink     =   String.permlinkWith(string: prefixTitle.isEmpty ? message : prefixTitle)

        let message_id          =   EOSTransaction.Mssgid(author: userId, permlink: messagePermlink)
        
        let parent_id           =   (parentPermlink == nil && parentAuthor == nil) ? EOSTransaction.Mssgid(author: "", permlink: "") : EOSTransaction.Mssgid(author: parentAuthor!, permlink: parentPermlink!)
        
        let messageCreateArgs   =   EOSTransaction.MessageCreateArgs(
            commun_code:    CyberSymbolWriterValue(name: communCode),
            message_id:     message_id,
            parent_id:      parent_id,
            header:         headermssgValue,
            body:           message,
            tags:           StringCollectionWriterValue(value: tags),
            metadata:       "",
            weight:         0)
        
        return EOSManager.create(messageCreateArgs: messageCreateArgs)
            .map {(transactionId: $0, userId: userId, permlink: messagePermlink)}
    }
    
    public func deleteMessage(permlink: String) -> Completable {
       
        
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(author: author, messagePermlink: permlink)
        return EOSManager.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(
        communCode:      String,
        permlink:         String,
        parentAuthor:     String? = nil,
        parentPermlink:   String? = nil,
        headline:         String?,
        message:          String,
        tags:             [String] = []
    ) -> Single<SendPostCompletion> {
       
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let parent_id           =   (parentPermlink == nil && parentAuthor == nil) ? nil : EOSTransaction.Mssgid(author: parentAuthor!, permlink: parentPermlink!)
        
        let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(
            commun_code: communCode,
            message_id: EOSTransaction.Mssgid(author: author, permlink: permlink),
            parent_id: parent_id,
            header: headline ?? "",
            body: message,
            tags: StringCollectionWriterValue(value: tags))
        
        return EOSManager.update(messageArgs: messageUpdateArgs)
            .map {(transactionId: $0, userId: author, permlink: permlink)}
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       headermssg:          String,
                       bodymssg:            String) -> Single<String> {
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        return EOSManager.reblog(args: reblogArgs)
    }
    
    // MARK: - Contract `gls.social`
    public func update(userProfile: [String: String]) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let userProfileAccountmetaArgs = EOSTransaction.UserProfileAccountmetaArgs(json: userProfile)
        
        let userProfileMetaArgs = EOSTransaction.UserProfileUpdatemetaArgs(accountValue:    userID,
                                                                           metaValue:       userProfileAccountmetaArgs)
        
        return EOSManager.update(userProfileMetaArgs: userProfileMetaArgs)
    }
    
    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<String> {
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let pinArgs = EOSTransaction.UserProfilePinArgs(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }
    
    public func block(_ userToBlock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let args = EOSTransaction.BlockUserArgs(blocker: userID, blocking: userToBlock)
        return EOSManager.block(args: args)
    }
    
    // MARK: - Contract `commun.list`
    public func followCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let followArgs = EOSTransaction.CommunListFollowArgs(
            commun_code: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.followCommunity(followArgs)
    }

    public func unfollowCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let unFollowArgs = EOSTransaction.CommunListFollowArgs(
            commun_code: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unfollowCommunity(unFollowArgs)
    }
    
    // MARK: - Contract `commun.ctrl`
    public func voteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let args = EOSTransaction.VoteLeaderArgs(commun_code: communityId, voter: userID, leader: leader)
        return EOSManager.voteLeader(args: args)
    }
    
    public func unvoteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        let args = EOSTransaction.UnvoteLeaderArgs(commun_code: communityId, voter: userID, leader: leader)
        return EOSManager.unvoteLeader(args: args)
    }
}

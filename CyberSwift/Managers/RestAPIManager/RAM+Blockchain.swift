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
    
    public func createMessage(
        isComment: Bool = false,
        communCode: String,
        parentAuthor: String? = nil,
        parentPermlink: String? = nil,
        header: String = "",
        body: String,
        tags: [String] = []
    ) -> Single<SendPostCompletion> {
        // Check for authorization
        guard let userId = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        // Create permlink for comment
        var permlink: String
        if isComment {
            permlink = String.permlinkWith(string: "comment")
        } else {
            // Create permlink for post
            permlink = String.permlinkWith(string: header.isEmpty ? body : header)
        }
        
        // Prepare arguments
        let messageId = EOSTransaction.Mssgid(author: userId, permlink: permlink)
        
        var parentId: EOSTransaction.Mssgid?
        if let parentAuthor = parentAuthor, let parentPermlink = parentPermlink {
            parentId = EOSTransaction.Mssgid(author: parentAuthor, permlink: parentPermlink)
        } else {
            parentId = EOSTransaction.Mssgid()
        }
        
        let args = EOSTransaction.MessageCreateArgs(
            commun_code:    CyberSymbolWriterValue(name: communCode),
            message_id:     messageId,
            parent_id:      parentId,
            header:         header,
            body:           body,
            tags:           StringCollectionWriterValue(value: tags),
            metadata:       "",
            weight:         0)
        
        // Send request
        return EOSManager.create(messageCreateArgs: args)
            .map {(transactionId: $0, userId: userId, permlink: permlink)}
            .observeOn(MainScheduler.instance)
    }
    
    public func deleteMessage(permlink: String) -> Completable {
       
        
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(author: author, messagePermlink: permlink)
        return EOSManager.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(
        communCode: String,
        permlink:   String,
        header:     String = "",
        body:       String,
        tags:       [String] = []
    ) -> Single<SendPostCompletion> {
       
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        // prepare args
        let messageId = EOSTransaction.Mssgid(author: author, permlink: permlink)
        let args = EOSTransaction.MessageUpdateArgs(
            commun_code:    communCode,
            message_id:     messageId,
            header:         header,
            body:           body,
            tags:           StringCollectionWriterValue(value: tags),
            metadata:       "")
        
        return EOSManager.update(messageArgs: args)
            .map {(transactionId: $0, userId: author, permlink: permlink)}
            .observeOn(MainScheduler.instance)
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
    
    // MARK: - Contract `commun.social`
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
    
    public func unblock(_ userToUnblock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let args = EOSTransaction.BlockUserArgs(blocker: userID, blocking: userToUnblock)
        return EOSManager.unblock(args: args)
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

    public func report(communityID: String,
                       autorID: String,
                       permlink: String,
                       reason: ReportReason) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSTransaction.ReprotArgs(communityID: communityID, userID: userID, autorID: autorID, permlink: permlink, reason: reason.rawValue)
        return EOSManager.report(args: args)
    }

    public enum ReportReason: String, CaseIterable {
        case spam = "Spam"
        case harassment = "Harassment"
        case niguty = "Niguty"
        case violence = "Violence"
        case fakeNews = "Fake News"
        case terrorism = "Terrorism"
        case hateSpeech = "Hate Speech"
        case unauthorizedSales = "Unauthorized Sales"
    }
}

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

extension RestAPIManager {
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
        parentPost: ResponseAPIContentGetPost? = nil,
        isReplying: Bool = false,
        parentComment: ResponseAPIContentGetComment? = nil,
        communCode: String,
        parentAuthor: String? = nil,
        parentPermlink: String? = nil,
        header: String = "",
        block: ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
        // Check for authorization
        guard let userId = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        guard let bodyString = try? block.jsonString() else {
            return .error(ErrorAPI.invalidData(message: "Body is invalid"))
        }
        
        // Create permlink for comment
        var permlink: String
        if isComment {
            permlink = String.permlinkWith(string: "comment-\(userId)-\(Int.random(in: 0..<100))")
        } else {
            // Create permlink for post
            permlink = String.permlinkWith(string: header.isEmpty ? bodyString : header)
        }
        
        // Prepare arguments
        let messageId = EOSTransaction.Mssgid(author: userId, permlink: permlink)
        
        var parentId: EOSTransaction.Mssgid?
        if let parentAuthor = parentAuthor, let parentPermlink = parentPermlink {
            parentId = EOSTransaction.Mssgid(author: parentAuthor, permlink: parentPermlink)
        } else {
            parentId = EOSTransaction.Mssgid()
        }
        
        // Send mock data
        var newComment: ResponseAPIContentGetComment?
        var parentComment = parentComment
        if isComment {
            // New comment
            if !isReplying {
                newComment = ResponseAPIContentGetComment(
                    contentId: ResponseAPIContentId(userId: userId, permlink: permlink, communityId: communCode),
                    parents: ResponseAPIContentGetCommentParent(post: ResponseAPIContentId(userId: userId, permlink: permlink, communityId: communCode), comment: nil),
                    document: block,
                    author: ResponseAPIAuthor(userId: userId, username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                    community: parentPost?.community)
                newComment?.status = .editing
                var parentPost = parentPost
                parentPost?.notifyCommentAdded(newComment!)
            }
            // Reply
            else {
                newComment = ResponseAPIContentGetComment(
                    contentId: ResponseAPIContentId(userId: userId, permlink: permlink, communityId: parentPost?.community.communityId ?? ""),
                    parents: ResponseAPIContentGetCommentParent(post: nil, comment: parentComment?.contentId),
                    document: block,
                    author: ResponseAPIAuthor(userId: userId, username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                    community: parentPost?.community)
                newComment?.status = .editing
                parentComment?.addChildComment(newComment!)
                
                var parentPost = parentPost
                let commentsCount = (parentPost?.stats?.commentsCount ?? 0) + 1
                parentPost?.stats?.commentsCount = commentsCount
                parentPost?.notifyChanged()
            }
        }
        
        // Send request
        let tags = block.getTags()
        let args = EOSTransaction.MessageCreateArgs(
            commun_code:    CyberSymbolWriterValue(name: communCode),
            message_id:     messageId,
            parent_id:      parentId,
            header:         header,
            body:           bodyString,
            tags:           StringCollectionWriterValue(value: tags),
            metadata:       "",
            weight:         0)
        
        return EOSManager.create(messageCreateArgs: args)
            .map {(transactionId: $0, userId: userId, permlink: permlink)}
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { (_) in
                if isComment {
                    if isReplying {
                        newComment?.status = .done
                        newComment?.notifyChanged()
                    }
                    else {
                        newComment?.status = .done
                        newComment?.notifyChanged()
                    }
                }
            }, onError: { (error) in
                if isComment {
                    if isReplying {
                        newComment?.status = .error
                        newComment?.notifyChanged()
                    }
                    else {
                        newComment?.status = .error
                        newComment?.notifyChanged()
                    }
                }
            })
    }
    
    public func deleteMessage(communCode: String, permlink: String) -> Completable {
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(
            commun_code: CyberSymbolWriterValue(name: communCode),
            message_id: EOSTransaction.Mssgid(author: author, permlink: permlink)
        )
        return EOSManager.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(
        originMessage: Decodable,
        communCode: String,
        permlink:   String,
        header:     String = "",
        block:       ResponseAPIContentBlock
    ) -> Single<SendPostCompletion> {
       
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        guard let bodyString = try? block.jsonString() else {
            return .error(ErrorAPI.invalidData(message: "Body is invalid"))
        }
        
        var originBlock: ResponseAPIContentBlock?
        var originMessage = originMessage
        // send mock playholder
        if var post = originMessage as? ResponseAPIContentGetPost {
            originBlock = post.document
            post.document = block
            post.status = .editing
            post.notifyChanged()
            originMessage = post
        }
        else if var comment = originMessage as? ResponseAPIContentGetComment {
            originBlock = comment.document
            comment.document = block
            comment.status = .editing
            comment.notifyChanged()
            originMessage = comment
        }
        
        // prepare args
        let messageId = EOSTransaction.Mssgid(author: author, permlink: permlink)
        let tags = block.getTags()
        let args = EOSTransaction.MessageUpdateArgs(
            commun_code:    CyberSymbolWriterValue(name: communCode),
            message_id:     messageId,
            header:         header,
            body:           bodyString,
            tags:           StringCollectionWriterValue(value: tags),
            metadata:       "")
        
        return EOSManager.update(messageArgs: args)
            .map {(transactionId: $0, userId: author, permlink: permlink)}
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { (_) in
                if var post = originMessage as? ResponseAPIContentGetPost {
                    post.status = .done
                    post.notifyChanged()
                }
                else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.status = .done
                    comment.notifyChanged()
                }
            }, onError: { (_) in
                if var post = originMessage as? ResponseAPIContentGetPost {
                    post.status = .error
                    post.notifyChanged()
                }
                else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.status = .error
                    comment.notifyChanged()
                }
            })
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
    
    public func hideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let args = EOSTransaction.CommunListFollowArgs(
            commun_code: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )
        
        return EOSManager.hideCommunity(args)
    }
    
    public func unhideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let args = EOSTransaction.CommunListFollowArgs(
            commun_code: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )
        
        return EOSManager.unhideCommunity(args)
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
                       reasons: [ReportReason]) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        // Change False News to falsenews
        let stringReasons = reasons.map { (reason) -> String in
            let reasons = reason.rawValue.components(separatedBy: " ")
            let normalizeTag = reasons.map({$0.lowercased()}).joined(separator: "")
            return "\"\(normalizeTag)\""
        }

        let args = EOSTransaction.ReprotArgs(communityID: communityID, userID: userID, autorID: autorID, permlink: permlink, reason: "[\(stringReasons.joined(separator: ", "))]")
        return EOSManager.report(args: args)
    }

    public enum ReportReason: String, CaseIterable {
        case spam = "Spam"
        case harassment = "Harassment"
        case niguty = "Niguty"
        case violence = "Violence"
        case falseNews = "False News"
        case terrorism = "Terrorism"
        case hateSpeech = "Hate Speech"
        case unauthorizedSales = "Unauthorized Sales"
    }
}

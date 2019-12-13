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
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {
        // Check for authorization
        guard let userId = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        // Create permlink for comment
        var permlink: String
        if isComment {
            permlink = String.permlinkWith(string: parentComment?.contentId.permlink ?? parentPost?.contentId.permlink ?? "comment", isComment: true)
        } else {
            // Create permlink for post
            permlink = String.permlinkWith(string: header.isEmpty ? "" : header)
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
        var parentPost = parentPost
        if isComment {
            // New comment
            if !isReplying {
                newComment = ResponseAPIContentGetComment(
                    contentId: ResponseAPIContentId(userId: userId, permlink: permlink, communityId: communCode),
                    parents: ResponseAPIContentGetCommentParent(post: ResponseAPIContentId(userId: parentAuthor ?? "", permlink: parentPermlink ?? "", communityId: communCode), comment: nil),
                    document: block,
                    author: ResponseAPIAuthor(userId: userId, username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                    community: parentPost?.community,
                    placeHolderImage: uploadingImage
                )
                newComment?.sendingState = .adding
                newComment?.votes.hasUpVote = true
                newComment?.votes.upCount = 1
                parentPost?.notifyCommentAdded(newComment!)
            }
            // Reply
            else {
                newComment = ResponseAPIContentGetComment(
                    contentId: ResponseAPIContentId(userId: userId, permlink: permlink, communityId: parentPost?.community?.communityId ?? ""),
                    parents: ResponseAPIContentGetCommentParent(post: nil, comment: parentComment?.contentId),
                    document: block,
                    author: ResponseAPIAuthor(userId: userId, username: Config.currentUser?.name, avatarUrl: UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey), stats: nil, isSubscribed: nil),
                    community: parentPost?.community,
                    placeHolderImage: uploadingImage
                )
                newComment?.sendingState = .replying
                newComment?.votes.hasUpVote = true
                newComment?.votes.upCount = 1
                parentComment?.addChildComment(newComment!)
                
                var parentPost = parentPost
                let commentsCount = (parentPost?.stats?.commentsCount ?? 0) + 1
                parentPost?.stats?.commentsCount = commentsCount
                parentPost?.notifyChanged()
            }
        }
        
        // Send request
        var single: Single<ResponseAPIContentBlock>?
        if isComment, let image = uploadingImage
        {
            single = RestAPIManager.instance.uploadImage(image)
                .observeOn(MainScheduler.instance)
                .flatMap {url in
                    var block = block
                    
                    var array = block.content.arrayValue ?? []
                    
                    array.append(
                        ResponseAPIContentBlock(id: (block.maxId ?? 0) + 1, type: "attachments", attributes: nil, content: .array([
                            ResponseAPIContentBlock(id: (block.maxId ?? 0) + 2, type: "image", attributes: nil, content: .string(url))
                        ]))
                    )
                    
                    block.content = .array(array)
                    return .just(block)
                }
        }
        
        var finalBlock: ResponseAPIContentBlock?
        return (single ?? .just(block))
            .map {block -> EOSTransaction.MessageCreateArgs in
                guard let bodyString = try? block.jsonString() else {
                    throw ErrorAPI.invalidData(message: "Body is invalid")
                }
                
                finalBlock = block
                
                let tags = block.getTags()
                return EOSTransaction.MessageCreateArgs(
                    commun_code:    CyberSymbolWriterValue(name: communCode),
                    message_id:     messageId,
                    parent_id:      parentId,
                    header:         header,
                    body:           bodyString,
                    tags:           StringCollectionWriterValue(value: tags),
                    metadata:       "",
                    weight:         0)
            }
            .flatMap {args in
                EOSManager.create(messageCreateArgs: args)
                    .map {(transactionId: $0, userId: userId, permlink: permlink)}
                    .observeOn(MainScheduler.instance)
            }
            .do(onSuccess: { (_) in
                if isComment {
                    newComment?.sendingState = MessageSendingState.none
                    newComment?.document = finalBlock
                    newComment?.placeHolderImage = nil
                    newComment?.notifyChanged()
                }
            }, onError: { (error) in
                if isComment {
                    if isReplying {
                        newComment?.sendingState = .error(state: .replying)
                        newComment?.notifyChanged()
                        let commentsCount = (parentComment?.childCommentsCount ?? 0) - 1
                        parentComment?.childCommentsCount = commentsCount
                        parentComment?.notifyChanged()
                    }
                    else {
                        newComment?.sendingState = .error(state: .adding)
                        newComment?.notifyChanged()
                    }
                    let commentsCount = (parentPost?.stats?.commentsCount ?? 0) - 1
                    parentPost?.stats?.commentsCount = commentsCount
                    parentPost?.notifyChanged()
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
        block:       ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {
       
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        var originBlock: ResponseAPIContentBlock?
        var originMessage = originMessage
        // send mock placeholder
        var single: Single<ResponseAPIContentBlock>?
        
        if var post = originMessage as? ResponseAPIContentGetPost {
            originBlock = post.document
            post.document = block
            post.sendingState = .editing
            post.notifyChanged()
            originMessage = post
        }
        else if var comment = originMessage as? ResponseAPIContentGetComment {
            originBlock = comment.document
            comment.document = block
            comment.placeHolderImage = UIImageDumbDecodable(image: uploadingImage)
            comment.sendingState = .editing
            comment.notifyChanged()
            originMessage = comment
            
            if let image = uploadingImage
            {
                single = RestAPIManager.instance.uploadImage(image)
                    .observeOn(MainScheduler.instance)
                    .flatMap {url in
                        var block = block
                        
                        var array = block.content.arrayValue ?? []
                        
                        array.append(
                            ResponseAPIContentBlock(id: (block.maxId ?? 0) + 1, type: "attachments", attributes: nil, content: .array([
                                ResponseAPIContentBlock(id: (block.maxId ?? 0) + 2, type: "image", attributes: nil, content: .string(url))
                            ]))
                        )
                        
                        block.content = .array(array)
                        return .just(block)
                    }
            }
        }
        
        // prepare args
        var finalBlock: ResponseAPIContentBlock?
        return (single ?? .just(block))
            .map {block -> EOSTransaction.MessageUpdateArgs in
                guard let bodyString = try? block.jsonString() else {
                    throw ErrorAPI.invalidData(message: "Body is invalid")
                }
                
                finalBlock = block
                
                let messageId = EOSTransaction.Mssgid(author: author, permlink: permlink)
                
                let tags = block.getTags()
                return EOSTransaction.MessageUpdateArgs(
                    commun_code:    CyberSymbolWriterValue(name: communCode),
                    message_id:     messageId,
                    header:         header,
                    body:           bodyString,
                    tags:           StringCollectionWriterValue(value: tags),
                    metadata:       "")
            }
            .flatMap {args in
                EOSManager.update(messageArgs: args)
                    .map {(transactionId: $0, userId: author, permlink: permlink)}
            }
            .observeOn(MainScheduler.instance)
            .do(onSuccess: { (_) in
                if var post = originMessage as? ResponseAPIContentGetPost {
                    post.sendingState = MessageSendingState.none
                    post.notifyChanged()
                }
                else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.sendingState = MessageSendingState.none
                    comment.document = finalBlock
                    comment.placeHolderImage = nil
                    comment.notifyChanged()
                }
            }, onError: { (_) in
                if var post = originMessage as? ResponseAPIContentGetPost {
                    post.sendingState = .error(state: .editing)
                    post.notifyChanged()
                }
                else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.sendingState = .error(state: .editing)
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

//
//  BlockchainManager+Message.swift
//  CyberSwift
//
//  Created by Chung Tran on 4/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension BlockchainManager {
    // MARK: - Create
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
            return .error(CMError.unauthorized())
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
        let messageId = EOSArgument.MessageIDContent(author: userId, permlink: permlink)

        var parentId: EOSArgument.MessageIDContent?
        if let parentAuthor = parentAuthor, let parentPermlink = parentPermlink {
            parentId = EOSArgument.MessageIDContent(author: parentAuthor, permlink: parentPermlink)
        } else {
            parentId = EOSArgument.MessageIDContent()
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
        if isComment, let image = uploadingImage {
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
            .map {block -> EOSArgument.CreateContent in
                guard let bodyString = try? block.jsonString() else {
                    throw CMError.invalidRequest(message: ErrorMessage.bodyIsInvalid.rawValue)
                }

                finalBlock = block

                let tags = block.getTags()
                return EOSArgument.CreateContent(
                    communCode: CyberSymbolWriterValue(name: communCode),
                    message_id: messageId,
                    parentID: parentId,
                    header: header,
                    body: bodyString,
                    tags: StringCollectionWriterValue(value: tags),
                    metadata: "",
                    weight: 0)
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
                    } else {
                        newComment?.sendingState = .error(state: .adding)
                        newComment?.notifyChanged()
                    }
                    let commentsCount = (parentPost?.stats?.commentsCount ?? 0) - 1
                    parentPost?.stats?.commentsCount = commentsCount
                    parentPost?.notifyChanged()
                }
            })
    }
    
    // MARK: - Update
    public func updateMessage(
        originMessage: Decodable,
        communCode: String,
        permlink: String,
        header: String = "",
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {

        guard let author = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        var originMessage = originMessage
        // send mock placeholder
        var single: Single<ResponseAPIContentBlock>?

        if var post = originMessage as? ResponseAPIContentGetPost {
            post.document = block
            post.sendingState = .editing
            post.notifyChanged()
            originMessage = post
        } else if var comment = originMessage as? ResponseAPIContentGetComment {
            comment.document = block
            comment.placeHolderImage = UIImageDumbDecodable(image: uploadingImage)
            comment.sendingState = .editing
            comment.notifyChanged()
            originMessage = comment

            if let image = uploadingImage {
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
            .map {block -> EOSArgument.UpdateContent in
                guard let bodyString = try? block.jsonString() else {
                    throw CMError.invalidRequest(message: ErrorMessage.bodyIsInvalid.rawValue)
                }

                finalBlock = block

                let messageId = EOSArgument.MessageIDContent(author: author, permlink: permlink)

                let tags = block.getTags()
                return EOSArgument.UpdateContent(
                    communCode: CyberSymbolWriterValue(name: communCode),
                    messageID: messageId,
                    header: header,
                    body: bodyString,
                    tags: StringCollectionWriterValue(value: tags),
                    metadata: "")
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
                } else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.sendingState = MessageSendingState.none
                    comment.document = finalBlock
                    comment.placeHolderImage = nil
                    comment.notifyChanged()
                }
            }, onError: { (_) in
                if var post = originMessage as? ResponseAPIContentGetPost {
                    post.sendingState = .error(state: .editing)
                    post.notifyChanged()
                } else if var comment = originMessage as? ResponseAPIContentGetComment {
                    comment.sendingState = .error(state: .editing)
                    comment.notifyChanged()
                }
            })
    }
    
    // MARK: - Delete
    public func deleteMessage<T: ResponseAPIContentMessageType>(
        _ message: T
    ) -> Completable {
        deleteMessageWithCommunCode(
            message.community?.communityId ?? "",
            permlink: message.contentId.permlink
        )
            .do(onCompleted: {
                message.notifyDeleted()
            })
    }
    
    // MARK: - Report
    public func report(communityID: String,
                       autorID: String,
                       permlink: String,
                       reasons: [ReportReason],
                       message: String? = nil) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        // Change False News to falsenews
        var stringReasons = reasons.filter({$0 != ReportReason.other}).map { (reason) -> String in
            let reasons = reason.rawValue.components(separatedBy: " ")
            let normalizeTag = reasons.map({$0.lowercased()}).joined(separator: "")
            return "\"\(normalizeTag)\""
        }

        if let message = message {
            stringReasons.append("\"other-\(message)\"")
        }

        let args = EOSArgument.ReportContent(communityID: communityID, userID: userID, authorID: autorID, permlink: permlink, reason: "[\(stringReasons.joined(separator: ", "))]")
        return EOSManager.report(args: args)
    }
    
    // MARK: - Vote
    public func upvoteMessage<T: ResponseAPIContentMessageType>(
        _ message: T
    ) -> Completable {
        // save original state
        let originHasUpVote = message.votes.hasUpVote ?? false
        let originHasDownVote = message.votes.hasDownVote ?? false
        
        // change state
        var message = message
        message.setHasVote(originHasUpVote ? false: true, for: .upvote)
        message.setHasVote(false, for: .downvote)
        message.votes.isBeingVoted = true
        message.notifyChanged()
        
        // send request
        return vote(
            voteType: originHasUpVote ? .unvote: .upvote,
            communityId: message.community?.communityId ?? "",
            author: message.contentId.userId,
            permlink: message.contentId.permlink
        )
            .observeOn(MainScheduler.instance)
            .do(onError: { (_) in
                message.setHasVote(originHasUpVote, for: .upvote)
                message.setHasVote(originHasDownVote, for: .downvote)
                message.votes.isBeingVoted = false
                message.notifyChanged()
            }, onCompleted: {
                // re-enable state
                message.votes.isBeingVoted = false
                message.notifyChanged()
            })
    }
    
    public func downvoteMessage<T: ResponseAPIContentMessageType>(
        _ message: T
    ) -> Completable {
        // save original state
        let originHasUpVote = message.votes.hasUpVote ?? false
        let originHasDownVote = message.votes.hasDownVote ?? false
        
        // change state
        var message = message
        message.setHasVote(originHasDownVote ? false: true, for: .downvote)
        message.setHasVote(false, for: .upvote)
        message.votes.isBeingVoted = true
        message.notifyChanged()
        
        // send request
        return vote(
            voteType: originHasDownVote ? .unvote: .downvote,
            communityId: message.community?.communityId ?? "",
            author: message.contentId.userId,
            permlink: message.contentId.permlink
        )
            .observeOn(MainScheduler.instance)
            .do(onError: { (_) in
                message.setHasVote(originHasUpVote, for: .upvote)
                message.setHasVote(originHasDownVote, for: .downvote)
                message.votes.isBeingVoted = false
                message.notifyChanged()
            }, onCompleted: {
                // re-enable state
                message.votes.isBeingVoted = false
                message.notifyChanged()
            })
    }
        
    // MARK: - Helpers
    private func deleteMessageWithCommunCode(_ communCode: String, permlink: String) -> Completable {
        guard let author = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let messageDeleteArgs = EOSArgument.DeleteContent(
            communCode: CyberSymbolWriterValue(name: communCode),
            messageID: EOSArgument.MessageIDContent(author: author, permlink: permlink)
        )
        return EOSManager.delete(messageArgs: messageDeleteArgs)
            .observeOn(MainScheduler.instance)
    }
    
    private func vote(
        voteType: VoteActionType,
        communityId: String,
        author: String,
        permlink: String
    ) -> Completable {
        return EOSManager.vote(voteType: voteType,
                               communityId: communityId,
                               author: author,
                               permlink: permlink)
            .flatMapToCompletable() //{RestAPIManager.instance.waitForTransactionWith(id: $0)}
    }
}

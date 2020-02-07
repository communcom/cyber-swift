//
//  BlockchainManager.swift
//  CyberSwift
//
//  Created by Artem Shilin on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

public typealias SendPostCompletion = (transactionId: String?, userId: String?, permlink: String?)

public class BlockchainManager {
    // MARK: - Properties
    public static let instance = BlockchainManager()
    private let communCurrencyName = Config.defaultSymbol

    // MARK: - Content Contracts
    public func vote(voteType: VoteActionType,
                     communityId: String,
                     author: String,
                     permlink: String) -> Completable {
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
                    throw ErrorAPI.invalidData(message: "Body is invalid")
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

    public func deleteMessage(communCode: String, permlink: String) -> Completable {
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let messageDeleteArgs = EOSArgument.DeleteContent(
            communCode: CyberSymbolWriterValue(name: communCode),
            messageID: EOSArgument.MessageIDContent(author: author, permlink: permlink)
        )
        return EOSManager.delete(messageArgs: messageDeleteArgs)
    }

    public func updateMessage(
        originMessage: Decodable,
        communCode: String,
        permlink: String,
        header: String = "",
        block: ResponseAPIContentBlock,
        uploadingImage: UIImage? = nil
    ) -> Single<SendPostCompletion> {

        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
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
                    throw ErrorAPI.invalidData(message: "Body is invalid")
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

    public func report(communityID: String,
                       autorID: String,
                       permlink: String,
                       reasons: [ReportReason],
                       message: String? = nil) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        // Change False News to falsenews
        var stringReasons = reasons.filter({$0 != ReportReason.other}).map { (reason) -> String in
            let reasons = reason.rawValue.components(separatedBy: " ")
            let normalizeTag = reasons.map({$0.lowercased()}).joined(separator: "")
            return "\"\(normalizeTag)\""
        }

        if let message = message {
            stringReasons.append("other-\(message)")
        }

        let args = EOSArgument.ReportContent(communityID: communityID, userID: userID, authorID: autorID, permlink: permlink, reason: "[\(stringReasons.joined(separator: ", "))]")
        return EOSManager.report(args: args)
    }

    // MARK: - Users Contracts
    public func update(userProfile: [String: String]) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let userProfileAccountmetaArgs = EOSArgument.UserProfileAccountmetaArgs(json: userProfile)

        let userProfileMetaArgs = EOSArgument.UpdateUser(accountValue: userID,
                                                                           metaValue: userProfileAccountmetaArgs)

        return EOSManager.update(userProfileMetaArgs: userProfileMetaArgs)
    }

    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let pinArgs = EOSArgument.PinUser(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }

    public func block(_ userToBlock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToBlock)
        return follow(userToBlock, isUnfollow: true)
            .flatMap {_ in EOSManager.block(args: args)}
    }

    public func unblock(_ userToUnblock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToUnblock)
        return EOSManager.unblock(args: args)
    }

    // MARK: - Communities Contracts
    public func followCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let followArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.followCommunity(followArgs)
    }

    public func unfollowCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let unFollowArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unfollowCommunity(unFollowArgs)
    }

    public func hideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
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
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unhideCommunity(args)
    }

    public func voteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.VoteLeader(communCode: communityId, voter: userID, leader: leader)
        return EOSManager.voteLeader(args: args)
    }

    public func unvoteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        let args = EOSArgument.UnvoteLeader(communCode: communityId, voter: userID, leader: leader)
        return EOSManager.unvoteLeader(args: args)
    }

    public func openCommunityBalance(communityCode: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let code = communityCode == communCurrencyName ? "4,\(communityCode)" : "3,\(communityCode)"

        let args = EOSArgument.OpenCommunBalance(owner: userID,
                                                 communCode: code,
                                                 ramPayer: userID)

        return EOSManager.openTokenBalance(args)
    }

    // MARK: - Wallet Contracts
    public func transferPoints(to: String,
                               number: Double,
                               currency: String) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: to, quantityValue: quantityFormatter(number: number, currency: currency), memoValue: "")

        if currency == communCurrencyName {
            return EOSManager.transferCommunToken(args)
        } else {
            return EOSManager.transferToken(args)
        }
    }

    public func buyPoints(communNumber: Double,
                          pointsCurrencyName: String) -> Single<String>  {

        guard let userID = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: BCAccountName.point.stringValue, quantityValue: quantityFormatter(number: communNumber, currency: communCurrencyName), memoValue: pointsCurrencyName)
        return EOSManager.buyToken(args)
    }

    public func sellPoints(number: Double, pointsCurrencyName: String) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: BCAccountName.point.stringValue, quantityValue: quantityFormatter(number: number, currency: pointsCurrencyName), memoValue: "")
        return EOSManager.sellToken(args)
    }
    
}

// MARK: - Helpers
extension BlockchainManager {
    private func quantityFormatter(number: Double, currency: String) -> String {
        let format = currency == communCurrencyName ? "%.4f" : "%.3f"
        return "\(String(format: format, number)) \(currency)"
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
        case abuse = "Attempt to abuse"
        case other = "Other"
    }
}

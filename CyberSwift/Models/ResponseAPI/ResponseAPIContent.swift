//
//  ResponseAPI+Content.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

// MARK: - MessageStatus
public indirect enum MessageSendingState: Decodable, Equatable {
    public init(from decoder: Decoder) throws {
        self = .none
    }
    
    case none
    case replying
    case editing
    case adding
    case error(state: MessageSendingState)
}

public protocol ResponseAPIContentMessageType: ListItemType {
    var votes: ResponseAPIContentVotes {get set}
    var document: ResponseAPIContentBlock? {get set}
    var community: ResponseAPIContentGetCommunity? {get}
    var contentId: ResponseAPIContentId {get}
    var sendingState: MessageSendingState? {get set}
}

extension ResponseAPIContentMessageType {
    mutating func setHasVote(_ value: Bool, for type: VoteActionType) {
        // return if nothing changes
        if type == .upvote && value == votes.hasUpVote {return}
        if type == .downvote && value == votes.hasDownVote {return}
        
        if type == .upvote {
            let voted = !(votes.hasUpVote ?? false)
            votes.hasUpVote = voted
            votes.upCount = (votes.upCount ?? 0) + (voted ? 1: -1)
        }
        
        if type == .downvote {
            let downVoted = !(votes.hasDownVote ?? false)
            votes.hasDownVote = downVoted
            votes.downCount = (votes.downCount ?? 0) + (downVoted ? 1: -1)
        }
    }
}

// MARK: - API `content.getPosts`
public struct ResponseAPIContentGetPosts: Decodable {
    public let items: [ResponseAPIContentGetPost]?
    public let sequenceKey: String?
}

public struct ResponseAPIContentGetPost: ResponseAPIContentMessageType {
    // MARK: - Nested type
    public enum TopExplanationType: String, Codable {
        case reward = "reward-what-does-it-mean"
        case hidden = "hidden"
    }
    public enum BottomExplanationType: String, Codable {
        case shareYourPost = "share-your-post"
        case rewardsForLikes = "rewards-for-likes"
        case rewardsForComments = "rewards-for-comment"
        case hidden = "hidden"
    }
    
    public var document: ResponseAPIContentBlock?
    public var votes: ResponseAPIContentVotes
    public let meta: ResponseAPIContentMeta
    public let contentId: ResponseAPIContentId
    public let author: ResponseAPIAuthor?
    public var stats: ResponseAPIContentGetPostStats?
    public let payout: ResponseAPIContentGetPostPayout?
    public var community: ResponseAPIContentGetCommunity?
    public let url: String?
    public let textLength: Int64?
    public var viewsCount: Int64?

    // Additional properties
    public var mosaic: ResponseAPIRewardsGetStateBulkMosaic?
    public var sendingState: MessageSendingState? = MessageSendingState.none
    
    // Explanation
    public var topExplanation: TopExplanationType?
    public var bottomExplanation: BottomExplanationType?
    
    // Donation
    public var donations: ResponseAPIWalletGetDonationsBulkItem?
    public var donationsCount: Int64 {
        donations?.totalAmount ?? 0
    }
    
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink + "/" + (self.community?.communityId ?? "")
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetPost) -> ResponseAPIContentGetPost? {
        guard self.identity == item.identity else {return nil}
        var topExplanation = self.topExplanation
        if topExplanation != .hidden {
            topExplanation = item.topExplanation ?? self.topExplanation
        }
        var bottomExplanation = self.bottomExplanation
        if bottomExplanation != .hidden {
            bottomExplanation = item.bottomExplanation ?? self.bottomExplanation
        }
        return ResponseAPIContentGetPost(
            document: item.document,
            votes: votes.newUpdatedItem(from: item.votes),
            meta: item.meta, contentId: item.contentId,
            author: item.author ?? self.author,
            stats: item.stats ?? self.stats,
            payout: item.payout ?? self.payout,
            community: item.community ?? self.community,
            url: item.url ?? self.url,
            textLength: item.textLength ?? self.textLength,
            viewsCount: item.viewsCount ?? self.viewsCount,
            mosaic: item.mosaic ?? self.mosaic,
            sendingState: item.sendingState ?? self.sendingState,
            topExplanation: topExplanation,
            bottomExplanation: bottomExplanation,
            donations: item.donations ?? donations
        )
    }
}

public struct ResponseAPIContentBlock: Codable, Equatable {
    public let id: UInt64?
    public let type: String
    public var attributes: ResponseAPIContentBlockAttributes?
    public var content: ResponseAPIContentBlockContent
    
    // for creating
    public var maxId: UInt64?
    
    public init(
        id: UInt64,
        type: String,
        attributes: ResponseAPIContentBlockAttributes?,
        content: ResponseAPIContentBlockContent
    ) {
        self.id = id
        self.type = type
        self.attributes = attributes
        self.content = content
    }
}

public enum ResponseAPIContentBlockContent: Codable, Equatable {
    public static func == (lhs: ResponseAPIContentBlockContent, rhs: ResponseAPIContentBlockContent) -> Bool {
        switch (lhs, rhs) {
        case (.array(let array1), .array(let array2)):
            return array1 == array2
        case (.string(let string1), .string(let string2)):
            return string1 == string2
        default:
            return false
        }
    }
    
    case array([ResponseAPIContentBlock])
    case string(String)
    case unsupported
}

public struct ResponseAPIContentBlockAttributes: Codable, Equatable {
    // PostBlock
    public var title: String?
    public var type: String?
    public var version: String?
    public var coverUrl: String?
    
    // TextBlock
    public var style: [String]?
    public var textColor: String?
    
    // LinkBlock
    public var url: String?
    
    // ImageBlock
    public var description: String?
    
    // VideoBlock
    public var providerName: String?
    public var author: String?
    public var authorUrl: String?
    public var thumbnailUrl: String?
    public var thumbnailSize: [UInt]?
    public var thumbnailWidth: UInt?
    public var thumbnailHeight: UInt?
    public var html: String?
    public var width: UInt?
    public var height: UInt?
    
    public init(
        title: String? = nil,
        type: String? = nil,
        version: String? = nil,
        style: [String]? = nil,
        textColor: String? = nil,
        url: String? = nil,
        description: String? = nil,
        providerName: String? = nil,
        author: String? = nil,
        authorUrl: String? = nil,
        thumbnailUrl: String? = nil,
        thumbnailSize: [UInt]? = nil,
        html: String? = nil,
        coverUrl: String? = nil,
        thumbnailHeight: UInt? = nil,
        thumbnailWidth: UInt? = nil,
        width: UInt? = nil,
        height: UInt? = nil
    ) {
        self.title = title
        self.type = type
        self.version = version
        self.style = style
        self.textColor = textColor
        self.url = url
        self.description = description
        self.providerName = providerName
        self.author = author
        self.authorUrl = authorUrl
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailSize = thumbnailSize
        self.html = html
        self.coverUrl = coverUrl
        self.thumbnailWidth = thumbnailWidth
        self.thumbnailHeight = thumbnailHeight
        self.width = width
        self.height = height
    }
}

public struct ResponseAPIContentEmbedResult: Decodable {
    public let type: String
    public let version: String
    public let title: String?
    public var url: String
    public let author: String?
    public let authorUrl: String?
    public let providerName: String?
    public let description: String?
    public var thumbnailUrl: String?
    public let thumbnailWidth: UInt64?
    public let thumbnailHeight: UInt64?
    public var html: String?
    public let contentLength: UInt64?
}

public struct ResponseAPIContentVotes: Decodable, Equatable {
    public var upCount: Int64?
    public var downCount: Int64?
    public var hasUpVote: Bool? = false
    public var hasDownVote: Bool? = false
    public var isBeingVoted: Bool? = false
    
    public func newUpdatedItem(from item: ResponseAPIContentVotes) -> ResponseAPIContentVotes {
        if item.isBeingVoted == nil && isBeingVoted == true {
            return self
        }
        
        return ResponseAPIContentVotes(upCount: item.upCount ?? upCount, downCount: item.downCount ?? downCount, hasUpVote: item.hasUpVote ?? hasUpVote, hasDownVote: item.hasDownVote ?? hasDownVote, isBeingVoted: item.isBeingVoted ?? isBeingVoted)
    }
}

public struct ResponseAPIContentGetPostStats: Decodable, Equatable {
    public let wilson: ResponseAPIContentGetPostStatsWilson?
    public var commentsCount: Int64
    public let rShares: Conflicted?
    public let hot: Double?
    public let trending: Double?
}

public struct ResponseAPIContentGetPostStatsWilson: Decodable, Equatable {
    public let hot: Double
    public let trending: Double
}

public struct ResponseAPIContentGetPostPayout: Decodable, Equatable {
    public let rShares: Conflicted?
}

public struct ResponseAPIContentId: Decodable, Equatable {
    public let userId: String
    public let permlink: String
    public let communityId: String?
    public let username: String?
    
    public init(userId: String, permlink: String, communityId: String?) {
        self.userId = userId
        self.permlink = permlink
        self.communityId = communityId
        self.username = nil
    }
}

public struct ResponseAPIContentMeta: Decodable, Equatable {
    public let creationTime: String
    public let updateTime: String?
    public let trxId: String?
}

// MARK: - API `content.waitForTransaction`
public struct ResponseAPIContentWaitForTransaction: Decodable {
    public let status: String
}

// MARK: - API `content.getComments`
public struct ResponseAPIContentGetComments: Decodable {
    public let items: [ResponseAPIContentGetComment]?
}

public struct ResponseAPIContentGetComment: ResponseAPIContentMessageType {
    public var votes: ResponseAPIContentVotes
    public let meta: ResponseAPIContentMeta
    public var childCommentsCount: UInt
    public let contentId: ResponseAPIContentId
    public let parents: ResponseAPIContentGetCommentParent
    public var document: ResponseAPIContentBlock?
    public let author: ResponseAPIAuthor?
    public let community: ResponseAPIContentGetCommunity?
    public var children: [ResponseAPIContentGetComment]?
    
    // Additional properties
    public var placeHolderImage: UIImageDumbDecodable?
    public var sendingState: MessageSendingState? = MessageSendingState.none
    
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetComment) -> ResponseAPIContentGetComment? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetComment(
            votes: votes.newUpdatedItem(from: item.votes),
            meta: item.meta,
            childCommentsCount: item.childCommentsCount,
            contentId: item.contentId,
            parents: item.parents, 
            document: item.document ?? self.document,
            author: item.author ?? self.author,
            community: item.community ?? self.community,
            children: item.children ?? self.children,
            placeHolderImage: item.placeHolderImage ?? self.placeHolderImage,
            sendingState: item.sendingState ?? self.sendingState
        )
    }
}

public struct ResponseAPIContentGetCommentPayout: Decodable {
    public let rShares: UInt64?
}

public struct ResponseAPIAuthor: Decodable, Equatable {
    public let userId: String
    public let username: String?
    public let avatarUrl: String?
    public let stats: ResponseAPIAuthorStats?
    public var isSubscribed: Bool?
    
    public init(userId: String, username: String?, avatarUrl: String?, stats: ResponseAPIAuthorStats?, isSubscribed: Bool?) {
        self.userId = userId
        self.username = username
        self.avatarUrl = avatarUrl
        self.stats = ResponseAPIAuthorStats(reputation: nil)
        self.isSubscribed = isSubscribed
    }
}

public struct ResponseAPIAuthorStats: Decodable, Equatable {
    public let reputation: Int64?
}

public struct ResponseAPIContentGetCommentParent: Decodable, Equatable {
    public let post: ResponseAPIContentId?
    public let comment: ResponseAPIContentId?
    
    public init(post: ResponseAPIContentId?, comment: ResponseAPIContentId?) {
        self.post = post
        self.comment = comment
    }
}

public struct ResponseAPIContentGetCommentParentCommentContent: Decodable {
    public let body: ResponseAPIContentGetCommentParentCommentContentBody?
}

public struct ResponseAPIContentGetCommentParentCommentContentBody: Decodable {
    public let preview: String?
}

// MARK: - API `content.getComments` by user
public struct ResponseAPIContentGetCommentParentPostContent: Decodable {
    public let title: String
}

public struct ResponseAPIContentGetCommentParentPostCommunity: Decodable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}

// MARK: - API `content.getReferralUsers`
public struct ResponseAPIContentGetReferralUsers: Decodable {
    public let items: [ResponseAPIContentGetProfile]
}

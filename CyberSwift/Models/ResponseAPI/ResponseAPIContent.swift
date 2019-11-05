//
//  ResponseAPI+Content.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// MARK: - API `content.getPosts`
public struct ResponseAPIContentGetPosts: Decodable {
    public let items: [ResponseAPIContentGetPost]?
    public let sequenceKey: String?
}

public struct ResponseAPIContentGetPost: Decodable {
    public var document: ResponseAPIContentBlock?
    public var votes: ResponseAPIContentVotes
    public let meta: ResponseAPIContentMeta
    public let contentId: ResponseAPIContentId
    public let author: ResponseAPIAuthor?
    public var stats: ResponseAPIContentGetPostStats?
    public let payout: ResponseAPIContentGetPostPayout?
    public let community: ResponseAPIContentGetCommunity
}

public struct ResponseAPIContentBlock: Codable, Equatable {
    public let id: UInt64
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
    
    // TextBlock
    public var style: [String]?
    public var text_color: String?
    
    // LinkBlock
    public var url: String?
    
    // ImageBlock
    public var description: String?
    
    // VideoBlock
    public var provider_name: String?
    public var author: String?
    public var author_url: String?
    public var thumbnail_url: String?
    public var thumbnail_size: [UInt]?
    public var html: String?
    
    public init(
        title: String? = nil,
        type: String? = nil,
        version: String? = nil,
        style: [String]? = nil,
        text_color: String? = nil,
        url: String? = nil,
        description: String? = nil,
        provider_name: String? = nil,
        author: String? = nil,
        author_url: String? = nil,
        thumbnail_url: String? = nil,
        thumbnail_size: [UInt]? = nil,
        html: String? = nil
    ){
        self.title = title
        self.type = type
        self.version = version
        self.style = style
        self.text_color = text_color
        self.url = url
        self.description = description
        self.provider_name = provider_name
        self.author = author
        self.author_url = author_url
        self.thumbnail_url = thumbnail_url
        self.thumbnail_size = thumbnail_size
        self.html = html
    }
}

public struct ResponseAPIContentEmbedResult: Decodable {
    public let type: String
    public let version: String
    public let title: String?
    public var url: String
    public let author: String?
    public let author_url: String?
    public let provider_name: String?
    public let description: String?
    public var thumbnail_url: String?
    public let thumbnail_width: UInt64?
    public let thumbnail_height: UInt64?
    public var html: String?
    public let content_length: UInt64?
}

public struct ResponseAPIContentVotes: Decodable {
    public var upCount: Int64?
    public var downCount: Int64?
    public var hasUpVote: Bool? = false
    public var hasDownVote: Bool? = false
}

public struct ResponseAPIContentGetPostStats: Decodable {
    public let wilson: ResponseAPIContentGetPostStatsWilson?
    public var commentsCount: UInt64
    public let rShares: Conflicted?
    public let hot: Double?
    public let trending: Double?
    public let viewCount: UInt64?
}

public struct ResponseAPIContentGetPostStatsWilson: Decodable {
    public let hot: Double
    public let trending: Double
}

public struct ResponseAPIContentGetPostPayout: Decodable {
    public let rShares: Conflicted?
}

public struct ResponseAPIContentId: Decodable {
    public let userId: String
    public let permlink: String
    public let communityId: String?
}

public struct ResponseAPIContentMeta: Decodable {
    public let creationTime: String
}

// MARK: - API `content.waitForTransaction`
public struct ResponseAPIContentWaitForTransaction: Decodable {
    public let status: String
}


// MARK: - API `content.getComments`
public struct ResponseAPIContentGetComments: Decodable {
    public let items: [ResponseAPIContentGetComment]?
}

public struct ResponseAPIContentGetComment: Decodable {
    public var votes: ResponseAPIContentVotes
    public let meta: ResponseAPIContentMeta
    public var childCommentsCount: UInt
    public let contentId: ResponseAPIContentId
    public let parents: ResponseAPIContentGetCommentParent
    public let document: ResponseAPIContentBlock
    public let author: ResponseAPIAuthor?
    public let community: ResponseAPIContentGetCommunity?
    public let children: [ResponseAPIContentGetComment]?
}

public struct ResponseAPIContentGetCommentVotes: Decodable {
    public let upCount: Int64?
    public let downCount: Int64?
    public let hasUpVote: Bool
    public let hasDownVote: Bool
}

public struct ResponseAPIContentGetCommentPayout: Decodable {
    public let rShares: UInt64?
}

public struct ResponseAPIAuthor: Decodable {
    public let userId: String
    public let username: String?
    public let avatarUrl: String?
    public let stats: ResponseAPIAuthorStats?
    public var isSubscribed: Bool?
}

public struct ResponseAPIAuthorStats: Decodable {
    public let reputation: Int64?
}

public struct ResponseAPIContentGetCommentParent: Decodable {
    public let post: ResponseAPIContentId?
    public let comment: ResponseAPIContentId?
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



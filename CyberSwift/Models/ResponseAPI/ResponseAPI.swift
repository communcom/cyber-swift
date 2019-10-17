//
//  ResponseAPI.swift
//  CyberSwift
//
//  Created by msm72 on 13.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation

public struct ResponseAPIResult<T: Decodable>: Decodable {
    public let id: UInt64
    public let jsonrpc: String
    public let result: T?
    public let error: ResponseAPIError?
}

/// [Multiple types](https://stackoverflow.com/questions/46759044/swift-structures-handling-multiple-types-for-a-single-property)
public struct Conflicted: Codable {
    public let stringValue: String?
    
    // Where we determine what type the value is
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            stringValue = try container.decode(String.self)
        } catch {
            do {
                stringValue = "\(try container.decode(Int64.self))"
            } catch {
                stringValue = ""
            }
        }
    }
    
    // We need to go back to a dynamic type, so based on the data we have stored, encode to the proper type
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
}

public enum StatusState: String {
    case ok         =   "OK"
    case error      =   "Error"
    case offline    =   "Offline"
}


// MARK: - Response Error
public struct ResponseAPIErrorResult: Decodable {
    // MARK: - In work
    public let error: ResponseAPIError
    public let id: Int64
    public let jsonrpc: String
}

public struct ResponseAPIError: Decodable {
    // MARK: - In work
    public let code: Int64
    public let message: String
    public let currentState: String?
    public let error: ResponseAPIErrorError?
}

public struct ResponseAPIErrorError: Decodable {
    public let code: Int64
    public let name: String
    public let what: String
    public let details: [ResponseAPIErrorErrorDetail]?
}

public struct ResponseAPIErrorErrorDetail: Decodable {
    public let message: String
}

// MARK: - API `content.resolveProfile`
public struct ResponseAPIContentResolveProfile: Decodable {
    public let userId: String
    public let username: String
    public let avatarUrl: String?
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: Decodable {
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public var blacklist: ResponseAPIContentGetProfileBlacklist?
    public let stats: ResponseAPIContentGetProfileStat
    public let leaderIn: [String]?
    public let userId: String
    public let username: String?
    public let registration: ResponseAPIContentGetProfileRegistration
    public let personal: ResponseAPIContentGetProfilePersonal
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public let createdAt: String?
}

public struct ResponseAPIContentGetProfileSubscription: Decodable {
    public var usersCount: UInt64?
    public var communitiesCount: UInt64?
    public let userIds: [ResponseAPIContentGetProfileSubscriptionUserID?]?
    public let communities: [ResponseAPIContentGetProfileSubscriptionCommunity?]?
}

public struct ResponseAPIContentGetProfileSubscriptionUserID: Decodable {
    public let id: String
    public let avatarUrl: String?
}

public struct ResponseAPIContentGetProfileSubscriptionCommunity: Decodable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}

public struct ResponseAPIContentGetProfileRegistration: Decodable {
    public let time: String
}

public struct ResponseAPIContentGetProfileStat: Decodable {
    public let reputation: Int64
    public let postsCount: Int64
    public let commentsCount: Int64
}

public struct ResponseAPIContentGetProfilePersonal: Decodable {
    public let contacts: ResponseAPIContentGetProfileContact?
    public let avatarUrl: String?
    public let coverUrl: String?
    public let biography: String?
}

public struct ResponseAPIContentGetProfileSubscriber: Decodable {
    public var usersCount: UInt64
    public let communitiesCount: UInt64
}

public struct ResponseAPIContentGetProfileBlacklist: Decodable {
    public var userIds: [String]
    public var communityIds: [String]
}

public struct ResponseAPIContentGetProfileContact: Decodable {
    public let facebook: String?
    public let telegram: String?
    public let whatsApp: String?
    public let weChat: String?
}

public struct ResponseAPIContentGetProfileSubscribers: Decodable {
    public let usersCount: UInt64
    public let communitiesCount: UInt64
}


// MARK: - API `content.getFeed`

public struct ResponseAPIContentGetPosts: Decodable {
    public let items: [ResponseAPIContentGetPost]?
    public let sequenceKey: String?
}

public struct ResponseAPIContentGetPost: Decodable {
    public var content: ResponseAPIContentBlock
    public var votes: ResponseAPIContentVotes
    public let meta: ResponseAPIContentMeta
    public let contentId: ResponseAPIContentId
    public let author: ResponseAPIAuthor?
    public var stats: ResponseAPIContentGetPostStats?
    public let payout: ResponseAPIContentGetPostPayout?
    public let community: ResponseAPIContentGetCommunity
}

public struct ResponseAPIContentBlock: Codable {
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

public enum ResponseAPIContentBlockContent: Codable {
    case array([ResponseAPIContentBlock])
    case string(String)
    case unsupported
}

public struct ResponseAPIContentBlockAttributes: Codable {
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
    public let content: ResponseAPIContentBlock
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


// MARK: - API `auth.authorize`
public struct ResponseAPIAuthAuthorize: Decodable {
    public let user: String
    public let username: String
    public let userId: String
    public let roles: [ResponseAPIAuthAuthorizeRole]?
    public let permission: String
}

public struct ResponseAPIAuthAuthorizeRole: Decodable {
    //    public let title: String?
}

public struct ResponseAPIAuthGenerateSecret: Decodable {
    public let secret: String
}


// MARK: - API `registration.getState`
public struct ResponseAPIRegistrationGetState: Decodable {
    public let currentState: String
    public let user: String?
}


// MARK: - API `registration.firstStep`
public struct ResponseAPIRegistrationFirstStep: Decodable {
    public let code: UInt64?
    public let strategy: String
    public let nextSmsRetry: String
}


// MARK: - API `registration.verify`
public struct ResponseAPIRegistrationVerify: Decodable {
    public let status: String
}


// MARK: - API `registration.setUsername`
public struct ResponseAPIRegistrationSetUsername: Decodable {
    public let status: String
}


// MARK: - API `registration.resendSmsCode`
public struct ResponseAPIResendSmsCode: Decodable {
    public let nextSmsRetry: String
    public let code: UInt64
}


// MARK: - API `registration.toBlockChain`
public struct ResponseAPIRegistrationToBlockChain: Decodable {
    public let userId: String
    public let username: String
}


// MARK: - API `push.notifyOn`
public struct ResponseAPINotifyPushOn: Decodable {
    public let status: String
}


// MARK: - API `push.notifyOff`
public struct ResponseAPINotifyPushOff: Decodable {
    public let status: String
}


// MARK: - API `push.historyFresh`
public struct ResponseAPIPushHistoryFresh: Decodable {
    //    public let status: String
}


// MARK: - API `onlineNotify.history`
public struct ResponseAPIOnlineNotifyHistory: Decodable {
    public let total: Int64
    public let data: [ResponseAPIOnlineNotificationData]
}

public struct ResponseAPIOnlineNotificationData: Decodable {
    public let _id: String
    public let timestamp: String
    public let eventType: String
    public let fresh: Bool
    public var unread: Bool
    
    public let community: ResponseAPIOnlineNotificationDataComunity?
    public let actor: ResponseAPIOnlineNotificationDataActor?
    public let post: ResponseAPIOnlineNotificationDataPost?
    public let comment: ResponseAPIOnlineNotificationDataComment?
    public let value: ResponseAPIOnlineNotificationDataValue?
}

public struct ResponseAPIOnlineNotificationDataComunity: Decodable {
    public let id: String
    public let name: String
}

public struct ResponseAPIOnlineNotificationDataActor: Decodable {
    public let userId: String?
    public let username: String?
    public let avatarUrl: String?
}

public struct ResponseAPIOnlineNotificationDataPost: Decodable {
    public let contentId: ResponseAPIContentId
    public let title: String?
}

public struct ResponseAPIOnlineNotificationDataComment: Decodable {
    public let contentId: ResponseAPIContentId
    public let body: String
}

public struct ResponseAPIOnlineNotificationDataValue: Decodable {
    public let amount: String
    public let currency: String
}


// MARK: - API `onlineNotify.historyFresh`
public struct ResponseAPIOnlineNotifyHistoryFresh: Decodable {
    public let fresh: UInt16
    public let freshByTypes: ResponseAPIOnlineNotifyHistoryFreshFreshByTypes
}

public struct ResponseAPIOnlineNotifyHistoryFreshFreshByTypes: Decodable {
    public let summary: UInt16
    public let upvote: UInt16
    public let downvote: UInt16
    public let transfer: UInt16
    public let reply: UInt16
    public let subscribe: UInt16
    public let unsubscribe: UInt16?
    public let mention: UInt16
    public let repost: UInt16
    public let reward: UInt16
    public let curatorReward: UInt16
    public let message: UInt16?
    public let witnessVote: UInt16?
    public let witnessCancelVote: UInt16?
}


// MARK: - API `notify.markAllAsRead`
public struct ResponseAPINotifyMarkAllAsViewed: Decodable {
    public let status: String
}


// MARK: - API `options.get`
public struct ResponseAPIGetOptions: Decodable {
    public let basic: ResponseAPIGetOptionsBasic?
    public let notify: ResponseAPIGetOptionsNotify
    public let push: ResponseAPIGetOptionsNotifyPush
}

public struct ResponseAPIGetOptionsBasic: Decodable {
    public let language: String?
    public let nsfwContent: String?
}

public struct ResponseAPIGetOptionsNotify: Decodable {
    public let show: ResponseAPIGetOptionsNotifyShow
}

public struct ResponseAPIGetOptionsNotifyShow: Decodable {
    public var upvote: Bool
    public var downvote: Bool
    public var transfer: Bool
    public var reply: Bool
    public var subscribe: Bool
    public var unsubscribe: Bool
    public var mention: Bool
    public var repost: Bool
    public var reward: Bool
    public var curatorReward: Bool
    public var witnessVote: Bool
    public var witnessCancelVote: Bool
}

public struct ResponseAPIGetOptionsNotifyPush: Decodable {
    public let lang: String
    public let show: ResponseAPIGetOptionsNotifyShow
}

// MARK: - API `options.set` basic
public struct ResponseAPISetOptionsBasic: Decodable {
    public let status: String
}


// MARK: - API `options.set` notice
public struct ResponseAPISetOptionsNotice: Decodable {
    public let status: String
}


// MARK: - API `notify.markAsRead`
public struct ResponseAPIMarkNotifiesAsRead: Decodable {
    public let status: String
}


// MARK: - API `meta.recordPostView`
public struct ResponseAPIMetaRecordPostView: Decodable {
    public let status: String
}


// MARK: - API `favorites.get`
public struct ResponseAPIGetFavorites: Decodable {
    public let list: [String?]
}


// MARK: - API `favorites.add`
public struct ResponseAPIAddFavorites: Decodable {
    public let status: String
}


// MARK: - API `favorites.remove`
public struct ResponseAPIRemoveFavorites: Decodable {
    public let status: String
}

// MARK: - API `content.getCommunity`
public struct ResponseAPIContentGetCommunity: Decodable {
    public let communityId: String?
    public let alias: String?
    public let name: String?
    public let avatarUrl: String?
    public let language: String?
    public let subscribersCount: UInt16?
    public let isSubscribed: Bool?
}

// MARK: - API `content.getCommunities`
public struct ResponseAPIContentGetCommunities: Decodable {
    public let communities: [ResponseAPIContentGetCommunity]
}

// MARK: - Generate new testnet accounts
public struct ResponseAPICreateNewAccount: Decodable {
    public let active_key: String
    public let alias: String
    public let comment_id: UInt16
    public let owner_key: String
    public let posting_key: String
    public let user_db_id: UInt64
    public let username: String
}

// MARK: - API `bandwidth.provide`
public struct ResponseAPIBandwidthProvide: Decodable {
    public let transaction_id: String
}

// MARK: - API `frame.getEmbed`
public struct ResponseAPIFrameGetEmbedResult: Decodable {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIFrameGetEmbed?
    public let error: ResponseAPIError?
}

public struct ResponseAPIFrameGetEmbed: Codable {
    public var type: String?
    public let version: String?
    public let title: String?
    public var url: String?
    public let author: String?
    public let author_url: String?
    public let provider_name: String?
    public let description: String?
    public let thumbnail_url: String?
    public let thumbnail_width: UInt?
    public let thumbnail_height: UInt?
    public var html: String?
    public let content_length: UInt32?
}

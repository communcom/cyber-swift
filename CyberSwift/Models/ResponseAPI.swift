//
//  ResponseAPI.swift
//  CyberSwift
//
//  Created by msm72 on 13.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation

/// Result type
public protocol ResponseAPIHasError {
    var error: ResponseAPIError? {get}
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


// MARK: -
public struct ResponseAPIErrorResult: Decodable {
    // MARK: - In work
    public let error: ResponseAPIError
    public let id: Int64
    public let jsonrpc: String
}


// MARK: -
public struct ResponseAPIError: Decodable {
    // MARK: - In work
    public let code: Int64
    public let message: String
    public let currentState: String?
}


// MARK: -
public struct ResponseAPIContentGetProfileResult: Decodable, ResponseAPIHasError {
    // MARK: - In work API `content.getProfile`
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetProfile?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIContentGetProfile: Decodable {
    // MARK: - In work API `content.getProfile`
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public let stats: ResponseAPIContentGetProfileStat
    public let userId: String
    public let username: String?
    public let registration: ResponseAPIContentGetProfileRegistration
    public let createdAt: String
    public let personal: ResponseAPIContentGetProfilePersonal
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public var isSubscribed: Bool?
}

// MARK: -
public struct ResponseAPIContentGetProfileSubscription: Decodable {
    // MARK: - In work API `content.getProfile`
    public var usersCount: UInt64?
    public var communitiesCount: UInt64?
    public let userIds: [ResponseAPIContentGetProfileSubscriptionUserID?]?
    public let communities: [ResponseAPIContentGetProfileSubscriptionCommunity?]?
}


// MARK: -
public struct ResponseAPIContentGetProfileSubscriptionUserID: Decodable {
    // MARK: - In work API `content.getProfile`
    public let id: String
    public let avatarUrl: String?
}


// MARK: -
public struct ResponseAPIContentGetProfileSubscriptionCommunity: Decodable {
    // MARK: - In work API `content.getProfile`
    public let id: String
    public let name: String
    public let avatarUrl: String?
}


// MARK: -
public struct ResponseAPIContentGetProfileRegistration: Decodable {
    // MARK: - In work API `content.getProfile`
    public let time: String
}


// MARK: -
public struct ResponseAPIContentGetProfileStat: Decodable {
    // MARK: - In work API `content.getProfile`
    public let postsCount: Int64
    public let commentsCount: Int64
}


// MARK: -
public struct ResponseAPIContentGetProfilePersonal: Decodable {
    // MARK: - In work API `content.getProfile`
    public let contacts: ResponseAPIContentGetProfileContact?
    public let avatarUrl: String?
    public let coverUrl: String?
    public let biography: String?
}


// MARK: -
public struct ResponseAPIContentGetProfileSubscriber: Decodable {
    // MARK: - In work API `content.getProfile`
    public var usersCount: UInt64
    public let communitiesCount: UInt64
}


// MARK: -
public struct ResponseAPIContentGetProfileContact: Decodable {
    // MARK: - In work API `content.getProfile`
    public let facebook: String?
    public let telegram: String?
    public let whatsApp: String?
    public let weChat: String?
}


// MARK: -
public struct ResponseAPIContentGetProfileSubscribers: Decodable {
    public let usersCount: UInt64
    public let communitiesCount: UInt64
}


// MARK: -
public struct ResponseAPIContentGetFeedResult: Decodable, ResponseAPIHasError {
    // MARK: - In work API `content.getFeed`
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetFeed?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIContentGetFeed: Decodable {
    // MARK: - In work API `content.getFeed`
    public let items: [ResponseAPIContentGetPost]?
    public let sequenceKey: String?
}


// MARK: -
public struct ResponseAPIContentGetPost: Decodable {
    // MARK: - In work API `content.getFeed`
    public let content: ResponseAPIContentGetPostContent
    public var votes: ResponseAPIContentVotes
    public let stats: ResponseAPIContentGetPostStats
    public let payout: ResponseAPIContentGetPostPayout
    public let contentId: ResponseAPIContentId
    public let meta: ResponseAPIContentGetPostMeta
    public let author: ResponseAPIAuthor?
    public let community: ResponseAPIContentGetPostCommunity
}


// MARK: -
public struct ResponseAPIContentGetPostContent: Decodable {
    // MARK: - In work API `content.getFeed`
    public let body: ResponseAPIContentGetPostContentBody
    public let title: String
    public let tags: [String?]?
    public let metadata: ResponseAPIContentGetPostContentMetadata?
    public let embeds: [ResponseAPIContentEmbed]
}


// MARK: -
public struct ResponseAPIContentGetPostContentBody: Decodable {
    // MARK: - In work API `content.getFeed`
    public let preview: String?
    
    // MARK: - In work API `content.getPost`
    public let full: String?
}


// MARK: - API `content.getFeed`
public struct ResponseAPIContentGetPostContentMetadata: Decodable {
    public let embeds: [ResponseAPIContentGetPostContentMetadataEmbed]?
}

public struct ResponseAPIContentEmbed: Decodable {
    public let _id: String
    public let id: String?
    public let type: String?
    public let result: ResponseAPIContentEmbedResult?
}

public struct ResponseAPIContentEmbedResult: Decodable {
    public let type: String
    public let version: String
    public let title: String?
    public let url: String
    public let author: String?
    public let author_url: String?
    public let provider_name: String?
    public let description: String?
    public let thumbnail_url: String?
    public let thumbnail_width: UInt64?
    public let thumbnail_height: UInt64?
    public let html: String?
    public let content_length: UInt64?
}

public struct ResponseAPIContentGetPostContentMetadataEmbed: Decodable {
    public let url: String?
    public let result: ResponseAPIContentGetPostContentMetadataEmbedResult?
    public let id: Conflicted
    public let html: String?
    public let type: String?
}

public struct ResponseAPIContentGetPostContentMetadataEmbedResult: Decodable {
    public let type: String
    public let version: String
    public let title: String
    public let url: String
    public let author: String
    public let author_url: String
    public let provider_name: String
    public let description: String
    public let thumbnail_url: String
    public let thumbnail_width: UInt16
    public let thumbnail_height: UInt16
    public let html: String
}

public struct ResponseAPIContentVotes: Decodable {
    public let upCount: Int64?
    public let downCount: Int64?
    public var hasUpVote: Bool
    public var hasDownVote: Bool
}

public struct ResponseAPIContentGetPostStats: Decodable {
    public let wilson: ResponseAPIContentGetPostStatsWilson?
    public let commentsCount: UInt64
    public let rShares: Conflicted?
    public let hot: Double
    public let trending: Double
    public let viewCount: UInt64
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
    public let refBlockNum: UInt64?
}

public struct ResponseAPIContentGetPostMeta: Decodable {
    public let time: String
}

public struct ResponseAPIContentGetPostCommunity: Decodable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}


// MARK: - API `content.getPost`
public struct ResponseAPIContentGetPostResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetPost?
    public let error: ResponseAPIError?
}


// MARK: - API `content.waitForTransaction`
public struct ResponseAPIContentWaitForTransactionResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentWaitForTransaction?
    public let error: ResponseAPIError?
}

public struct ResponseAPIContentWaitForTransaction: Decodable {
    public let status: String
}


// MARK: - API `content.getComments`
public struct ResponseAPIContentGetCommentsResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetComments?
    public let error: ResponseAPIError?
}

public struct ResponseAPIContentGetComments: Decodable {
    public let items: [ResponseAPIContentGetComment]?
    public let sequenceKey: String?
}

public struct ResponseAPIContentGetComment: Decodable {
    public let content: ResponseAPIContentGetCommentContent
    public var votes: ResponseAPIContentVotes
    public let payout: ResponseAPIContentGetCommentPayout
    public let contentId: ResponseAPIContentId
    public let meta: ResponseAPIContentGetCommentMeta
    public let author: ResponseAPIAuthor?
    public let parent: ResponseAPIContentGetCommentParent
    public let parentComment: ResponseAPIContentGetCommentParentComment?
}

public struct ResponseAPIContentGetCommentContent: Decodable {
    public let body: ResponseAPIContentGetCommentContentBody
    public let metadata: ResponseAPIContentGetCommentContentMetadata?
    public let embeds: [ResponseAPIContentEmbed]
}

public struct ResponseAPIContentGetCommentContentBody: Decodable {
    public let preview: String?
    public let full: String?
}

public struct ResponseAPIContentGetCommentContentMetadata: Decodable {
    public let app: String?
    public let format: String?
    public let tags: [String]?
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

public struct ResponseAPIContentGetCommentMeta: Decodable {
    public let time: String
}

public struct ResponseAPIAuthor: Decodable {
    public let userId: String
    public let username: String?
    public let avatarUrl: String?
    public let stats: ResponseAPIAuthorStats?
}

public struct ResponseAPIAuthorStats: Decodable {
    public let reputation: UInt64?
}

public struct ResponseAPIContentGetCommentParent: Decodable {
    public let post: ResponseAPIContentGetCommentParentPost?
    public let comment: ResponseAPIContentGetCommentParentComment?
}

public struct ResponseAPIContentGetCommentParentComment: Decodable {
    public let contentId: ResponseAPIContentId?
    public let content: ResponseAPIContentGetCommentParentCommentContent?
    public let author: ResponseAPIAuthor?
}

public struct ResponseAPIContentGetCommentParentCommentContent: Decodable {
    public let body: ResponseAPIContentGetCommentParentCommentContentBody?
}

public struct ResponseAPIContentGetCommentParentCommentContentBody: Decodable {
    public let preview: String?
}


// MARK: - API `content.getComments` by user
public struct ResponseAPIContentGetCommentParentPost: Decodable {
    public let content: ResponseAPIContentGetCommentParentPostContent?
    public let community: ResponseAPIContentGetCommentParentPostCommunity?
    
    // API `content.getComments` by post
    public let contentId: ResponseAPIContentId?
}

public struct ResponseAPIContentGetCommentParentPostContent: Decodable {
    public let title: String
}

public struct ResponseAPIContentGetCommentParentPostCommunity: Decodable {
    public let id: String
    public let name: String
    public let avatarUrl: String?
}


// MARK: - API `auth.authorize`
public struct ResponseAPIAuthAuthorizeResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIAuthAuthorize?
    public let error: ResponseAPIError?
}

public struct ResponseAPIAuthAuthorize: Decodable {
    public let user: String
    public let displayName: String
    public let roles: [ResponseAPIAuthAuthorizeRole]?
    public let permission: String
}

public struct ResponseAPIAuthAuthorizeRole: Decodable {
    //    public let title: String?
}

public struct ResponseAPIAuthGenerateSecretResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIAuthGenerateSecret?
    public let error: ResponseAPIError?
}

public struct ResponseAPIAuthGenerateSecret: Decodable {
    public let secret: String
}


// MARK: - API `registration.getState`
public struct ResponseAPIRegistrationGetStateResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIRegistrationGetState?
    public let error: ResponseAPIError?
}

public struct ResponseAPIRegistrationGetState: Decodable {
    public let currentState: String
    public let user: String?
}


// MARK: - API `registration.firstStep`
public struct ResponseAPIRegistrationFirstStepResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIRegistrationFirstStep?
    public let error: ResponseAPIError?
}

public struct ResponseAPIRegistrationFirstStep: Decodable {
    public let code: UInt64
    public let strategy: String
    public let nextSmsRetry: String
    
    public init(code: UInt64 = 0, strategy: String = "", nextSmsRetry: String = "") {
        self.code           =   code
        self.strategy       =   strategy
        self.nextSmsRetry   =   nextSmsRetry
    }
}


// MARK: - API `registration.verify`
public struct ResponseAPIRegistrationVerifyResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIRegistrationVerify?
    public let error: ResponseAPIError?
}

public struct ResponseAPIRegistrationVerify: Decodable {
    public let status: String
}


// MARK: - API `registration.setUsername`
public struct ResponseAPIRegistrationSetUsernameResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIRegistrationSetUsername?
    public let error: ResponseAPIError?
}

public struct ResponseAPIRegistrationSetUsername: Decodable {
    public let status: String
}


// MARK: - API `registration.resendSmsCode`
public struct ResponseAPIResendSmsCodeResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIResendSmsCode?
    public let error: ResponseAPIError?
}

public struct ResponseAPIResendSmsCode: Decodable {
    public let nextSmsRetry: String
    public let code: UInt64
}


// MARK: - API `registration.toBlockChain`
public struct ResponseAPIRegistrationToBlockChainResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIRegistrationToBlockChain?
    public let error: ResponseAPIError?
}

public struct ResponseAPIRegistrationToBlockChain: Decodable {
    public let userId: String
    public let username: String
}


// MARK: - API `push.notifyOn`
public struct ResponseAPINotifyPushOnResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPINotifyPushOn?
    public let error: ResponseAPIError?
}

public struct ResponseAPINotifyPushOn: Decodable {
    public let status: String
}


// MARK: - API `push.notifyOff`
public struct ResponseAPINotifyPushOffResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPINotifyPushOff?
    public let error: ResponseAPIError?
}

public struct ResponseAPINotifyPushOff: Decodable {
    public let status: String
}


// MARK: - API `push.historyFresh`
public struct ResponseAPIPushHistoryFreshResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIPushHistoryFresh?
    public let error: ResponseAPIError?
}

public struct ResponseAPIPushHistoryFresh: Decodable {
    //    public let status: String
}


// MARK: - API `onlineNotify.history`
public struct ResponseAPIOnlineNotifyHistoryResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let result: ResponseAPIOnlineNotifyHistory?
    public let error: ResponseAPIError?
}

public struct ResponseAPIOnlineNotifyHistory: Decodable {
    public let total: Int64
    public let data: [ResponseAPIOnlineNotificationData]
}


// MARK: -
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


// MARK: -
public struct ResponseAPIOnlineNotificationDataComunity: Decodable {
    public let id: String
    public let name: String
}


// MARK: -
public struct ResponseAPIOnlineNotificationDataActor: Decodable {
    public let userId: String?
    public let username: String?
    public let avatarUrl: String?
}


// MARK: -
public struct ResponseAPIOnlineNotificationDataPost: Decodable {
    public let contentId: ResponseAPIContentId
    public let title: String?
}

// MARK: -
public struct ResponseAPIOnlineNotificationDataComment: Decodable {
    public let contentId: ResponseAPIContentId
    public let body: String
}

public struct ResponseAPIOnlineNotificationDataValue: Decodable {
    public let amount: String
    public let currency: String
}

// MARK: -
public struct ResponseAPIOnlineNotifyHistoryFreshResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt64
    public let result: ResponseAPIOnlineNotifyHistoryFresh?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIOnlineNotifyHistoryFresh: Decodable {
    public let fresh: UInt16
    public let freshByTypes: ResponseAPIOnlineNotifyHistoryFreshFreshByTypes
}


// MARK: -
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


// MARK: -
public struct ResponseAPINotifyMarkAllAsViewedResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPINotifyMarkAllAsViewed?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPINotifyMarkAllAsViewed: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPIGetOptionsResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIGetOptions?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIGetOptions: Decodable {
    public let basic: ResponseAPIGetOptionsBasic?
    public let notify: ResponseAPIGetOptionsNotify
    public let push: ResponseAPIGetOptionsNotifyPush
}


// MARK: -
public struct ResponseAPIGetOptionsBasic: Decodable {
    public let language: String?
    public let nsfwContent: String?
}


// MARK: -
public struct ResponseAPIGetOptionsNotify: Decodable {
    public let show: ResponseAPIGetOptionsNotifyShow
}


// MARK: -
public struct ResponseAPIGetOptionsNotifyShow: Decodable {
    public let upvote: Bool
    public let downvote: Bool
    public let transfer: Bool
    public let reply: Bool
    public let subscribe: Bool
    public let unsubscribe: Bool
    public let mention: Bool
    public let repost: Bool
    public let reward: Bool
    public let curatorReward: Bool
    public let message: Bool
    public let witnessVote: Bool
    public let witnessCancelVote: Bool
}


// MARK: -
public struct ResponseAPIGetOptionsNotifyPush: Decodable {
    public let lang: String
    public let show: ResponseAPIGetOptionsNotifyPushShow
}


// MARK: -
public struct ResponseAPIGetOptionsNotifyPushShow: Decodable {
    public let upvote: Bool
    public let downvote: Bool
    public let transfer: Bool
    public let reply: Bool
    public let subscribe: Bool
    public let unsubscribe: Bool
    public let mention: Bool
    public let repost: Bool
    public let reward: Bool
    public let curatorReward: Bool
    public let message: Bool
    public let witnessVote: Bool
    public let witnessCancelVote: Bool
}


// MARK: -
public struct ResponseAPISetOptionsBasicResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPISetOptionsBasic?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPISetOptionsBasic: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPISetOptionsNoticeResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPISetOptionsNotice?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPISetOptionsNotice: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPIMarkNotifiesAsReadResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIMarkNotifiesAsRead?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIMarkNotifiesAsRead: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPIMetaRecordPostViewResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIMetaRecordPostView?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIMetaRecordPostView: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPIGetFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIGetFavorites?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIGetFavorites: Decodable {
    public let list: [String?]
}


// MARK: -
public struct ResponseAPIAddFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIAddFavorites?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIAddFavorites: Decodable {
    public let status: String
}


// MARK: -
public struct ResponseAPIRemoveFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIRemoveFavorites?
    public let error: ResponseAPIError?
}


// MARK: -
public struct ResponseAPIRemoveFavorites: Decodable {
    public let status: String
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

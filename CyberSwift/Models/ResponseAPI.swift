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
}


// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfileResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetProfile?
    public let error: ResponseAPIError?
}

public struct ResponseAPIContentGetProfile: Decodable {
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
public struct ResponseAPIContentGetFeedResult: Decodable, ResponseAPIHasError {
    public let id: Int64
    public let jsonrpc: String
    public let result: ResponseAPIContentGetFeed?
    public let error: ResponseAPIError?
}

public struct ResponseAPIContentGetFeed: Decodable {
    public let items: [ResponseAPIContentGetPost]?
    public let sequenceKey: String?
}

public struct ResponseAPIContentGetPost: Decodable {
    public let content: ResponseAPIContentGetPostContent
    public var votes: ResponseAPIContentVotes
    public let stats: ResponseAPIContentGetPostStats
    public let payout: ResponseAPIContentGetPostPayout
    public let contentId: ResponseAPIContentId
    public let meta: ResponseAPIContentGetPostMeta
    public let author: ResponseAPIAuthor?
    public let community: ResponseAPIContentGetPostCommunity
}

public struct ResponseAPIContentGetPostContent: Decodable {
    public let body: ResponseAPIContentGetPostContentBody
    public let title: String
    public let tags: [String?]?
    public let metadata: ResponseAPIContentGetPostContentMetadata?
    public let embeds: [ResponseAPIContentEmbed]
}

public struct ResponseAPIContentGetPostContentBody: Decodable {
    public let preview: String?
    public let full: String?
}

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
    public var upCount: Int64?
    public var downCount: Int64?
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
    public let reputation: Int64?
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
    public let code: UInt64?
    public let strategy: String
    public let nextSmsRetry: String
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
public struct ResponseAPIOnlineNotifyHistoryFreshResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt64
    public let result: ResponseAPIOnlineNotifyHistoryFresh?
    public let error: ResponseAPIError?
}

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
public struct ResponseAPINotifyMarkAllAsViewedResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPINotifyMarkAllAsViewed?
    public let error: ResponseAPIError?
}

public struct ResponseAPINotifyMarkAllAsViewed: Decodable {
    public let status: String
}


// MARK: - API `options.get`
public struct ResponseAPIGetOptionsResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIGetOptions?
    public let error: ResponseAPIError?
}

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
public struct ResponseAPISetOptionsBasicResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPISetOptionsBasic?
    public let error: ResponseAPIError?
}

public struct ResponseAPISetOptionsBasic: Decodable {
    public let status: String
}


// MARK: - API `options.set` notice
public struct ResponseAPISetOptionsNoticeResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPISetOptionsNotice?
    public let error: ResponseAPIError?
}

public struct ResponseAPISetOptionsNotice: Decodable {
    public let status: String
}


// MARK: - API `notify.markAsRead`
public struct ResponseAPIMarkNotifiesAsReadResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIMarkNotifiesAsRead?
    public let error: ResponseAPIError?
}

public struct ResponseAPIMarkNotifiesAsRead: Decodable {
    public let status: String
}


// MARK: - API `meta.recordPostView`
public struct ResponseAPIMetaRecordPostViewResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIMetaRecordPostView?
    public let error: ResponseAPIError?
}

public struct ResponseAPIMetaRecordPostView: Decodable {
    public let status: String
}


// MARK: - API `favorites.get`
public struct ResponseAPIGetFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIGetFavorites?
    public let error: ResponseAPIError?
}

public struct ResponseAPIGetFavorites: Decodable {
    public let list: [String?]
}


// MARK: - API `favorites.add`
public struct ResponseAPIAddFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIAddFavorites?
    public let error: ResponseAPIError?
}

public struct ResponseAPIAddFavorites: Decodable {
    public let status: String
}


// MARK: - API `favorites.remove`
public struct ResponseAPIRemoveFavoritesResult: Decodable, ResponseAPIHasError {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIRemoveFavorites?
    public let error: ResponseAPIError?
}

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

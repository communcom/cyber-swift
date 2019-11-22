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
public struct Conflicted: Codable, Equatable {
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
    public let data: ResponseAPIErrorData?
}

public struct ResponseAPIErrorData: Decodable {
    public let code: Int64?
    public let message: String?
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
// {"jsonrpc":"2.0","id":1,"result":{"code":1234,"nextSmsRetry":"2019-10-30T09:51:27.649Z","currentState":"verify"}}
public struct ResponseAPIRegistrationFirstStep: Decodable {
    public let code: UInt64?
    public let currentState: String
    public let nextSmsRetry: String
}


// MARK: - API `registration.verify`
// {"jsonrpc":"2.0","id":3,"result":{"currentState":"setUsername"}}
public struct ResponseAPIRegistrationVerify: Decodable {
    public let currentState: String
}


// MARK: - API `registration.setUsername`
// {"jsonrpc":"2.0","id":3,"result":{"userId":"tst5osiwjzpx","currentState":"toBlockChain"}}
public struct ResponseAPIRegistrationSetUsername: Decodable {
    public let userId: String
    public let currentState: String
}


// MARK: - API `registration.resendSmsCode`
// {"jsonrpc":"2.0","id":3,"result":{"nextSmsRetry":"2019-10-30T10:05:08.338Z","currentState":"verify"}}
public struct ResponseAPIResendSmsCode: Decodable {
    public let nextSmsRetry: String
    public let currentState: String
}


// MARK: - API `registration.toBlockChain`
// {"jsonrpc":"2.0","id":3,"result":{"userId":"tst5gtbbviic","currentState":"toBlockChain"}}
public struct ResponseAPIRegistrationToBlockChain: Decodable {
    public let userId: String
    public let currentState: String
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

public struct ResponseAPIOnlineNotificationData: Decodable, Equatable {
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

public struct ResponseAPIOnlineNotificationDataComunity: Decodable, Equatable {
    public let id: String
    public let name: String
}

public struct ResponseAPIOnlineNotificationDataActor: Decodable, Equatable {
    public let userId: String?
    public let username: String?
    public let avatarUrl: String?
}

public struct ResponseAPIOnlineNotificationDataPost: Decodable, Equatable {
    public let contentId: ResponseAPIContentId
    public let title: String?
}

public struct ResponseAPIOnlineNotificationDataComment: Decodable, Equatable {
    public let contentId: ResponseAPIContentId
    public let body: String
}

public struct ResponseAPIOnlineNotificationDataValue: Decodable, Equatable {
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
    
    public static var allOn: ResponseAPIGetOptionsNotifyShow {
        ResponseAPIGetOptionsNotifyShow(upvote: true, downvote: true, transfer: true, reply: true, subscribe: true, unsubscribe: true, mention: true, repost: true, reward: true, curatorReward: true, witnessVote: true, witnessCancelVote: true)
    }
    public static var allOff: ResponseAPIGetOptionsNotifyShow {
        ResponseAPIGetOptionsNotifyShow(upvote: false, downvote: false, transfer: false, reply: false, subscribe: false, unsubscribe: false, mention: false, repost: false, reward: false, curatorReward: false, witnessVote: false, witnessCancelVote: false)
    }
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

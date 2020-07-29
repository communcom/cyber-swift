//
//  ResponseAPIContentProfile.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

public protocol ProfileType: ListItemType {
    var userId: String {get}
    var username: String {get}
    var isSubscribed: Bool? {get set}
    var subscribersCount: Int64? {get set}
    var identity: String {get}
    var isBeingToggledFollow: Bool? {get set}
    var isInBlacklist: Bool? {get set}
}

extension ProfileType {
    static var followedEventName: String {"Followed"}
    static var unfollowedEventName: String {"Unfollowed"}
    
    mutating func setIsSubscribed(_ value: Bool) {
        guard value != isSubscribed
        else {return}
        isSubscribed = value
        var subscribersCount: Int64 = (self.subscribersCount ?? 0)
        if value == false && subscribersCount == 0 {subscribersCount = 0} else {
            if value == true {
                subscribersCount += 1
            } else {
                subscribersCount -= 1
            }
        }
        self.subscribersCount = subscribersCount
    }
    
    public static func observeProfileFollowed() -> Observable<Self> {
        observeEvent(eventName: followedEventName)
    }
    
    public static func observeProfileUnfollowed() -> Observable<Self> {
        observeEvent(eventName: unfollowedEventName)
    }
}

extension ResponseAPIContentGetProfile: ProfileType {}
extension ResponseAPIContentGetLeader: ProfileType {}

// MARK: - QrCode
public struct QrCodeDecodedProfile: Decodable {
    public let userId: String?
    public let username: String
    public let password: String
}

// MARK: - API `content.getProfile`
public struct ResponseAPIContentGetProfile: Encodable, ListItemType {
    // FIXME: - Be careful, mark new properties as optional, please!!!
    public let stats: ResponseAPIContentGetProfileStat?
    public let leaderIn: [String]?
    public let userId: String
    public let username: String
    public let avatarUrl: String?
    public let coverUrl: String?
    public let registration: ResponseAPIContentGetProfileRegistration?
    public var subscribers: ResponseAPIContentGetProfileSubscriber?
    public let subscriptions: ResponseAPIContentGetProfileSubscription?
    public var personal: ResponseAPIContentGetProfilePersonal?
    public var isInBlacklist: Bool?
    public var isSubscribed: Bool?
    public var isSubscription: Bool?
    public var isBlocked: Bool?
    public var highlightCommunitiesCount: Int64?
    public var highlightCommunities: [ResponseAPIContentGetCommunity]?
    
    // content.resolveProfile
    public var postsCount: Int64?
    public var subscribersCount: Int64?
    
    // Additional properties
    public var isBeingToggledFollow: Bool? = false
    public var isBeingUnblocked: Bool? = false
    
    public var identity: String {
        return userId + "/" + username
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetProfile) -> ResponseAPIContentGetProfile? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIContentGetProfile(
            stats: item.stats ?? self.stats,
            leaderIn: item.leaderIn ?? self.leaderIn,
            userId: item.userId,
            username: item.username,
            avatarUrl: item.avatarUrl ?? self.avatarUrl,
            coverUrl: item.coverUrl ?? self.coverUrl,
            registration: item.registration ?? self.registration,
            subscribers: item.subscribers ?? self.subscribers,
            subscriptions: item.subscriptions ?? self.subscriptions,
            personal: item.personal ?? self.personal,
            isInBlacklist: item.isInBlacklist ?? self.isInBlacklist,
            isSubscribed: item.isSubscribed ?? self.isSubscribed,
            isSubscription: item.isSubscription ?? self.isSubscription,
            isBlocked: item.isBlocked ?? self.isBlocked,
            highlightCommunitiesCount: item.highlightCommunitiesCount ?? self.highlightCommunitiesCount,
            highlightCommunities: item.highlightCommunities ?? self.highlightCommunities,
            postsCount: item.postsCount ?? self.postsCount,
            subscribersCount: item.subscribersCount ?? self.subscribersCount,
            isBeingToggledFollow: item.isBeingToggledFollow ?? self.isBeingToggledFollow,
            isBeingUnblocked: item.isBeingUnblocked ?? self.isBeingUnblocked
        )
    }
    
    public static func with(userId: String, username: String, avatarUrl: String?, stats: ResponseAPIContentGetProfileStat?, isSubscribed: Bool?) -> ResponseAPIContentGetProfile {
        ResponseAPIContentGetProfile(stats: stats, leaderIn: nil, userId: userId, username: username, avatarUrl: avatarUrl, coverUrl: nil, registration: nil, subscriptions: nil, personal: nil, isSubscribed: isSubscribed)
    }

}

public struct ResponseAPIContentGetProfileSubscription: Codable, Equatable {
    public var usersCount: Int64?
    public var communitiesCount: Int64?
}

public struct ResponseAPIContentGetProfileRegistration: Codable, Equatable {
    public let time: String
}

public struct ResponseAPIContentGetProfileStat: Codable, Equatable {
    public let reputation: Int64?
    public let postsCount: Int64?
    public let commentsCount: Int64?
}

public struct ResponseAPIContentGetProfilePersonal: Codable, Equatable {
    public var contacts: ResponseAPIContentGetProfileContacts?
    public var biography: String?
    public var firstName: String?
    public var lastName: String?
    public var country: String?
    public var city: String?
    public var birthDate: String?
    
    public var fullName: String? {
        if firstName == nil && lastName == nil {return nil}
        if firstName == nil {return lastName}
        return firstName! + (lastName == nil ? "" : " \(lastName!)")
    }
}

public struct ResponseAPIContentGetProfileSubscriber: Codable, Equatable {
    public var usersCount: Int64?
    public let communitiesCount: Int64?
}

public struct ResponseAPIContentGetProfileBlacklist: Decodable {
    public var userIds: [String]
    public var communityIds: [String]
}

public struct ResponseAPIContentGetProfileContacts: Codable, Equatable {
    public var facebook: ResponseAPIContentGetProfileContact?
    public var telegram: ResponseAPIContentGetProfileContact?
    public var whatsApp: ResponseAPIContentGetProfileContact?
    public var weChat: ResponseAPIContentGetProfileContact?
    public var instagram: ResponseAPIContentGetProfileContact?
    public var linkedin: ResponseAPIContentGetProfileContact?
    public var twitter: ResponseAPIContentGetProfileContact?
    public var gitHub: ResponseAPIContentGetProfileContact?
    public var websiteUrl: ResponseAPIContentGetProfileContact?
    public var youtube: ResponseAPIContentGetProfileContact?
    public var email: ResponseAPIContentGetProfileContact?
    public var facetime: ResponseAPIContentGetProfileContact?
    public var facebookMessenger: ResponseAPIContentGetProfileContact?
    
    public init() {}
}

public struct ResponseAPIContentGetProfileContact: Codable, Equatable {
    public var stringValue: String?
    public var value: String?
    public var `default`: Bool?
    
    public init(value: String?, default: Bool?) {
        self.value = value
        self.default = `default`
    }
    
    // Where we determine what type the value is
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        
        let properString = string.replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
        
        if let data = properString.data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        {
            value = dict["value"] as? String
            `default` = dict["default"] as? Bool
            return
        }
        
        stringValue = string
    }
    
    // We need to go back to a dynamic type, so based on the data we have stored, encode to the proper type
    enum CodingKeys: String, CodingKey {
        case value
        case `default`
    }
    
    public func encode(to encoder: Encoder) throws {
        let boolValue = self.default == true ? "true": "false"
        let string = stringValue ?? "{\"value\":  \"\(value ?? "")\",\"default\": \(boolValue)}"
        
        var container = encoder.singleValueContainer()
        try container.encode(string)
    }
}

public struct ResponseAPIContentGetProfileSubscribers: Decodable {
    public let usersCount: Int64
    public let communitiesCount: Int64
}

// MARK: - API `content.getSubscribers`
public struct ResponseAPIContentGetSubscribers: Decodable {
    public let items: [ResponseAPIContentGetProfile]
}

// MARK: - API `content.getSubscriptions`
public struct ResponseAPIContentGetSubscriptions: Decodable {
    public let items: [ResponseAPIContentGetSubscriptionsItem]
}

public enum ResponseAPIContentGetSubscriptionsItem: ListItemType {
    public static func == (lhs: ResponseAPIContentGetSubscriptionsItem, rhs: ResponseAPIContentGetSubscriptionsItem) -> Bool {
        switch (lhs, rhs) {
        case (.user(let user), .user(let user2)):
            return user == user2
        case (.community(let com1), .community(let com2)):
            return com1 == com2
        default:
            return false
        }
    }
    
    case user(ResponseAPIContentGetProfile)
    case community(ResponseAPIContentGetCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetProfile.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetCommunity.self) {
            self = .community(communities)
            return
        }
        throw CMError.invalidResponse(message: ErrorMessage.unsupportedDataType.rawValue)
    }
    
    public var userValue: ResponseAPIContentGetProfile? {
        switch self {
        case .user(let user):
            return user
        default:
            return nil
        }
    }
    
    public var communityValue: ResponseAPIContentGetCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
    
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetSubscriptionsItem) -> ResponseAPIContentGetSubscriptionsItem? {
        guard item.identity == self.identity else {return nil}
        switch self {
        case .user(let userSelf):
            guard let newUser = item.userValue else {return nil}
            guard let updatedUser = userSelf.newUpdatedItem(from: newUser) else {return nil}
            return ResponseAPIContentGetSubscriptionsItem.user(updatedUser)
        case .community(let communitySelf):
            guard let newCommunity = item.communityValue else {return nil}
            guard let updatedCommunity = communitySelf.newUpdatedItem(from: newCommunity) else {return nil}
            return ResponseAPIContentGetSubscriptionsItem.community(updatedCommunity)
        }
    }
}

// MARK: - API `content.getBlacklist`
public struct ResponseAPIContentGetBlacklist: Decodable {
    public let items: [ResponseAPIContentGetBlacklistItem]
}

public enum ResponseAPIContentGetBlacklistItem: ListItemType {
    public static func == (lhs: ResponseAPIContentGetBlacklistItem, rhs: ResponseAPIContentGetBlacklistItem) -> Bool {
        switch (lhs, rhs) {
        case (.user(let user), .user(let user2)):
            return user == user2
        case (.community(let com1), .community(let com2)):
            return com1 == com2
        default:
            return false
        }
    }
    case user(ResponseAPIContentGetProfile)
    case community(ResponseAPIContentGetCommunity)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let users = try? container.decode(ResponseAPIContentGetProfile.self) {
            self = .user(users)
            return
        }
        if let communities = try? container.decode(ResponseAPIContentGetCommunity.self) {
            self = .community(communities)
            return
        }
        throw CMError.invalidResponse(message: ErrorMessage.unsupportedDataType.rawValue)
    }
    
    public var userValue: ResponseAPIContentGetProfile? {
        switch self {
        case .user(let user):
            return user
        default:
            return nil
        }
    }
    
    public var communityValue: ResponseAPIContentGetCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
    
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetBlacklistItem) -> ResponseAPIContentGetBlacklistItem? {
        guard item.identity == self.identity else {return nil}
        switch self {
        case .user(let userSelf):
            guard let newUser = item.userValue else {return nil}
            guard let updatedUser = userSelf.newUpdatedItem(from: newUser) else {return nil}
            return ResponseAPIContentGetBlacklistItem.user(updatedUser)
        case .community(let communitySelf):
            guard let newCommunity = item.communityValue else {return nil}
            guard let updatedCommunity = communitySelf.newUpdatedItem(from: newCommunity) else {return nil}
            return ResponseAPIContentGetBlacklistItem.community(updatedCommunity)
        }
    }
}

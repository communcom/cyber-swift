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
    var username: String? {get}
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
    public let stats: ResponseAPIContentGetProfileStat?
    public let leaderIn: [String]?
    public let userId: String
    public let username: String?
    public var avatarUrl: String?
    public var coverUrl: String?
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
    public var commonCommunitiesCount: Int64?
    
    // content.resolveProfile
    public var postsCount: Int64?
    public var subscribersCount: Int64?
    
    // Additional properties
    public var isBeingToggledFollow: Bool? = false
    public var isBeingUnblocked: Bool? = false
    
    public var createdCommunities: [ResponseAPIContentGetCommunity]?
    
    public var representationName: String? {
        personal?.fullName ?? username ?? userId
    }
    
    public var identity: String {
        return userId + "/" + (username ?? "")
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
            isBeingUnblocked: item.isBeingUnblocked ?? self.isBeingUnblocked,
            createdCommunities: item.createdCommunities ?? self.createdCommunities
        )
    }
    
    public static func with(userId: String, username: String, avatarUrl: String?, stats: ResponseAPIContentGetProfileStat?, isSubscribed: Bool?) -> ResponseAPIContentGetProfile {
        ResponseAPIContentGetProfile(stats: stats, leaderIn: nil, userId: userId, username: username, avatarUrl: avatarUrl, coverUrl: nil, registration: nil, subscriptions: nil, personal: nil, isSubscribed: isSubscribed, createdCommunities: nil)
    }

    public static var current: ResponseAPIContentGetProfile? {
        get {
            guard let data = UserDefaults.standard.data(forKey: Config.currentUserGetProfileKey) else {
                return nil
            }
            return try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: data)
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {return}
            UserDefaults.standard.set(data, forKey: Config.currentUserGetProfileKey)
        }
    }
    
    public static var observeCurrentProfile: Observable<ResponseAPIContentGetProfile?> {
        UserDefaults.standard.rx.observe(Data.self, Config.currentUserGetProfileKey)
            .map {$0 == nil ? nil : try? JSONDecoder().decode(ResponseAPIContentGetProfile.self, from: $0!)}
    }
    
    public static func updateCurrentUserProfile(
        avatarUrl: String? = nil,
        coverUrl: String? = nil,
        bio: String? = nil
    ) {
        var profile = ResponseAPIContentGetProfile.current
        if let avatarUrl = avatarUrl {
            profile?.avatarUrl = avatarUrl
        }
        if let coverUrl = coverUrl {
            profile?.coverUrl = coverUrl
        }
        if let bio = bio {
            profile?.personal?.biography = bio
        }
        
        ResponseAPIContentGetProfile.current = profile
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
    public var defaultContacts: [String]?
    public var messengers: ResponseAPIContentGetProfilePersonalMessengers?
    public var links: ResponseAPIContentGetProfilePersonalLinks?
    public var biography: String?
    public var firstName: String?
    public var lastName: String?
    public var country: String?
    public var city: String?
    public var birthDate: String?
    public var websiteUrl: String?
    
    public var fullName: String? {
        if firstName == nil && lastName == nil {return nil}
        if firstName == nil {return lastName}
        let fullName = firstName! + (lastName == nil ? "" : " \(lastName!)")
        if fullName.trimSpaces() == "" {return nil}
        return fullName
    }
}

public struct ResponseAPIContentGetProfilePersonalMessengers: Codable, Equatable {
    public enum MessengerType: String {
        case whatsApp, telegram, weChat
        
        public enum IdentifyType: String {
            case phoneNumber = "phone number"
            case username = "username"
            case link = "link"
        }

        public var identifiedBy: IdentifyType {
            switch self {
            case .weChat, .telegram:
                return .username
            case .whatsApp:
                return .phoneNumber
            }
        }
    }
    
    var supportedContacts: [MessengerType] { [.telegram] } // REMOVE LATER
    
    public var filledContacts: [MessengerType: ResponseAPIContentGetProfilePersonalLink] {
        var filledContacts = [MessengerType: ResponseAPIContentGetProfilePersonalLink]()
        if whatsApp?.value != nil {filledContacts[.whatsApp] = whatsApp}
        if telegram?.value != nil {filledContacts[.telegram] = telegram}
        if weChat?.value != nil {filledContacts[.weChat] = weChat}
        return filledContacts
            .filter {supportedContacts.contains($0.key)}
    }
    
    public var unfilledContacts: [MessengerType] {
        var unfilledContacts = [MessengerType]()
        if whatsApp?.value == nil {unfilledContacts.append(.whatsApp)}
        if telegram?.value == nil {unfilledContacts.append(.telegram)}
        if weChat?.value == nil {unfilledContacts.append(.weChat)}
        return unfilledContacts
            .filter {supportedContacts.contains($0)}
    }
    
    public func getContact(messengerType: MessengerType) -> ResponseAPIContentGetProfilePersonalLink? {
        switch messengerType {
        case .whatsApp:
            return whatsApp
        case .telegram:
            return telegram
        case .weChat:
            return weChat
        }
    }
    
    public var whatsApp: ResponseAPIContentGetProfilePersonalLink?
    public var telegram: ResponseAPIContentGetProfilePersonalLink?
    public var weChat: ResponseAPIContentGetProfilePersonalLink?
    
    public init() {}
}

public struct ResponseAPIContentGetProfilePersonalLinks: Codable, Equatable {
    public enum LinkType: String {
        case twitter
        case gitHub
        case facebook
        case instagram
        case linkedin
    }
    
    public var filledLinks: [LinkType: ResponseAPIContentGetProfilePersonalLink] {
        var filledLinks = [LinkType: ResponseAPIContentGetProfilePersonalLink]()
        if twitter?.value != nil {filledLinks[.twitter] = twitter}
        if facebook?.value != nil {filledLinks[.facebook] = facebook}
        if instagram?.value != nil {filledLinks[.instagram] = instagram}
        if linkedin?.value != nil {filledLinks[.linkedin] = linkedin}
        if gitHub?.value != nil {filledLinks[.gitHub] = gitHub}
        return filledLinks
    }
    
    public var unfilledLinks: [LinkType] {
        var unfilledLinks = [LinkType]()
        if twitter?.value == nil {unfilledLinks.append(.twitter)}
        if facebook?.value == nil {unfilledLinks.append(.facebook)}
        if instagram?.value == nil {unfilledLinks.append(.instagram)}
        if linkedin?.value == nil {unfilledLinks.append(.linkedin)}
        if gitHub?.value == nil {unfilledLinks.append(.gitHub)}
        return unfilledLinks
    }

    public func getLink(linkType: LinkType) -> ResponseAPIContentGetProfilePersonalLink? {
        switch linkType {
        case .facebook:
            return facebook
        case .instagram:
            return instagram
        case .linkedin:
            return linkedin
        case .twitter:
            return twitter
        case .gitHub:
            return gitHub
        }
    }

    public var twitter: ResponseAPIContentGetProfilePersonalLink?
    public var facebook: ResponseAPIContentGetProfilePersonalLink?
    public var gitHub: ResponseAPIContentGetProfilePersonalLink?
    public var instagram: ResponseAPIContentGetProfilePersonalLink?
    public var linkedin: ResponseAPIContentGetProfilePersonalLink?
    public init() {}
}

public struct ResponseAPIContentGetProfilePersonalLink: Codable, Equatable {
    public var value: String?
    public var `default`: Bool?
    public var href: String?
    
    public init(value: String?, defaultValue: Bool?, href: String? = nil) {
        self.value = value
        self.default = defaultValue
        self.href = href
    }
    
    public var encodedString: String {
        let boolValue = self.default == true ? "true": "false"
        return "{\"value\":\"\(value ?? "")\",\"default\":\(boolValue)}"
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

//
//  ResponseAPI+Notification.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

// MARK: - getNotifications
public struct ResponseAPIGetNotifications: Decodable {
    public var items: [ResponseAPIGetNotificationItem]
    public var lastNotificationTimestamp: String?
}

public struct ResponseAPIGetNotificationItem: ListItemType {
    public static var empty: ResponseAPIGetNotificationItem {
        ResponseAPIGetNotificationItem(id: "", eventType: "", timestamp: "", community: nil, userId: nil, author: nil, user: nil, isNew: false, voter: nil, entityType: nil, post: nil, comment: nil, from: nil, amount: nil, pointType: nil, tracery: nil)
    }
    
    public let id: String
    public let eventType: String
    public let timestamp: String
    public let community: ResponseAPIContentGetCommunity?
    public let userId: String?
    public let author: ResponseAPIContentGetProfile?
    public let user: ResponseAPIContentGetProfile?
    public var isNew: Bool
    public let voter: ResponseAPIContentGetProfile?
    public let entityType: String?
    public let post: ResponseAPIGetNotificationItemPost?
    public let comment: ResponseAPIGetNotificationItemComment?
    public let from: ResponseAPIContentGetProfile?
    public let amount: String?
    public let pointType: String?
    public let tracery: String?
    
    public var identity: String {id}
    
    public func newUpdatedItem(from item: ResponseAPIGetNotificationItem) -> ResponseAPIGetNotificationItem? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIGetNotificationItem(id: id, eventType: item.eventType, timestamp: item.timestamp, community: item.community ?? community, userId: item.userId ?? userId, author: item.author ?? author, user: item.user ?? self.user, isNew: item.isNew, voter: item.voter ?? self.voter, entityType: item.entityType ?? entityType, post: item.post ?? post, comment: item.comment ?? comment, from: item.from ?? self.from, amount: item.amount ?? self.amount, pointType: item.pointType ?? self.pointType, tracery: item.tracery ?? self.tracery)
    }
}

public struct ResponseAPIGetNotificationItemPost: Decodable, Equatable {
    public let contentId: ResponseAPIContentId
    public let shortText: String?
    public let imageUrl: String?
}

public struct ResponseAPIGetNotificationItemComment: Decodable, Equatable {
    public let contentId: ResponseAPIContentId
    public let shortText: String?
    public let imageUrl: String?
    public let parents: ResponseAPIGetNotificationItemCommentParents?
}

public struct ResponseAPIGetNotificationItemCommentParents: Decodable, Equatable {
    public let post: ResponseAPIContentId?
    public let comment: ResponseAPIContentId?
}

// MARK: - notifications.statusUpdated
public struct ResponseAPINotificationsStatusUpdated: Decodable, Equatable {
    public let unseenCount: UInt64
}

// MARK: - pushSettings
public struct ResponseAPISettingsGetPushSettings: Decodable, Equatable {
    public var disabled: [String]
}

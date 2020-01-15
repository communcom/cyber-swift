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
    var items: [ResponseAPIGetNotificationItem]
    var lastNotificationTimestamp: String
}

public struct ResponseAPIGetNotificationItem: ListItemType {
    let id: String
    let eventType: String
    let timestamp: String
    let userId: String
    let user: ResponseAPIContentResolveProfile?
    var isNew: Bool
    let voter: ResponseAPIContentResolveProfile?
    let entityType: String?
    let post: ResponseAPIGetNotificationItemPost?
    
    public var identity: String {id}
    
    public func newUpdatedItem(from item: ResponseAPIGetNotificationItem) -> ResponseAPIGetNotificationItem? {
        guard item.identity == self.identity else {return nil}
        return ResponseAPIGetNotificationItem(id: id, eventType: item.eventType, timestamp: item.timestamp, userId: item.userId, user: item.user ?? self.user, isNew: item.isNew, voter: item.voter ?? self.voter, entityType: item.entityType ?? entityType, post: item.post ?? post)
    }
}

public struct ResponseAPIGetNotificationItemPost: Decodable, Equatable {
    let contentId: ResponseAPIContentId
    let shortText: String?
    let imageUrl: String?
}

//
//  RAM+Notifications.swift
//  CyberSwift
//
//  Created by Chung Tran on 19/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

public enum NoticeType {
    case push
    case notify
}

extension RestAPIManager {
    // MARK: - New methods
    // API `notifications.getNotifications`
    public func getNotifications(
        limit: UInt = 20,
        beforeThan: String? = nil,
        filter: [String]? = nil
    ) -> Single<ResponseAPIGetNotifications> {
        var params = [String: Encodable]()
        params["limit"] = limit
        params["beforeThan"] = beforeThan
        if let filter = filter, filter.count > 0 {
            params["filter"] = filter
        }
        return executeGetRequest(methodGroup: .notifications, methodName: "getNotifications", params: params)
    }
    
    // API `notifications.getStatus`
    public func notificationsGetStatus() -> Single<ResponseAPINotificationsStatusUpdated> {
        executeGetRequest(methodGroup: .notifications, methodName: "getStatus", params: [:])
    }
    
    // API `notifications.markAsRead`
    public func notificationsMarkAsRead(_ ids: [String]) -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .notifications, methodName: "markAsRead", params: ["ids": ids])
    }
    
    // API `notifications.markAllAsViewed`
    public func notificationsMarkAllAsViewed(until: String) -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .notifications, methodName: "markAllAsViewed", params: ["until": until])
    }
    
    // API `settings.getPushSettings`
    public func notificationsGetPushSettings() -> Single<ResponseAPISettingsGetPushSettings> {
        executeGetRequest(methodGroup: .settings, methodName: "getPushSettings", params: [:])
    }
    
    // API `settings.setPushSettings`
    public func notificationsSetPushSettings(disable types: [String]) -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .settings, methodName: "setPushSettings", params: ["disable": types])
    }
}

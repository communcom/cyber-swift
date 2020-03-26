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
        let methodAPIType = MethodAPIType.getNotifications(limit: limit, beforeThan: beforeThan, filter: filter)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notifications.getStatus`
    public func notificationsGetStatus() -> Single<ResponseAPINotificationsStatusUpdated> {
        let methodAPIType = MethodAPIType.notificationsGetStatus
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notifications.markAsRead`
    public func notificationsMarkAsRead(_ ids: [String]) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.markAsRead(ids)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notifications.markAllAsViewed`
    public func notificationsMarkAllAsViewed(until: String) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.markAllAsViewed(until: until)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `settings.getPushSettings`
    public func notificationsGetPushSettings() -> Single<       ResponseAPISettingsGetPushSettings> {
        let methodAPIType = MethodAPIType.getPushSettings
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `settings.setPushSettings`
    public func notificationsSetPushSettings(disable types: [String]) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.setPushSettings(disabled: types)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

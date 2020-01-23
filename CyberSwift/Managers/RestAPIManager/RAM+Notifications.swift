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
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notifications.getStatus`
    public func notificationsGetStatus() -> Single<ResponseAPINotificationsStatusUpdated> {
        let methodAPIType = MethodAPIType.notificationsGetStatus
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notifications.markAsRead`
    public func notificationsMarkAsRead(_ ids: [String]) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.markAsRead(ids)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `settings.getPushSettings`
    public func notificationsGetPushSettings() -> Single<ResponseAPISettingsGetPushSettings> {
        let methodAPIType = MethodAPIType.getPushSettings
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `settings.setPushSettings`
    public func notificationsSetPushSettings(disable types: [String]) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.setPushSettings(disabled: types)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Old methods
    // API `push.historyFresh`
    public func getPushHistoryFresh() -> Single<ResponseAPIStatus> {
        
        let methodAPIType = MethodAPIType.getPushHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `onlineNotify.historyFresh`
    public func getOnlineNotifyHistoryFresh() -> Single<ResponseAPIOnlineNotifyHistoryFresh> {
        
        let methodAPIType = MethodAPIType.getOnlineNotifyHistoryFresh
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // API `notify.markAllAsViewed`
    public func notifyMarkAllAsViewed() -> Single<ResponseAPIStatus> {
        
        let methodAPIType = MethodAPIType.notifyMarkAllAsViewed
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

extension RestAPIManager {
    /// Turn on push notification
    public func pushNotifyOn() -> Completable {
        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let token = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            return .error(ErrorAPI.requestFailed(message: "Token not found"))
        }
        
        let methodAPIType = MethodAPIType.notifyPushOn(fcmToken: token, appProfileType: AppProfileType.golos)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIStatus>)
            .do(onSuccess: { _ in
                UserDefaults.standard.set(true, forKey: Config.currentUserPushNotificationOn)
            })
            .flatMapCompletable({ (_) -> Completable in
                // Turn on all options
                let value = ResponseAPIGetOptionsNotifyShow(upvote: true, downvote: true, transfer: true, reply: true, subscribe: true, unsubscribe: true, mention: true, repost: true, reward: true, curatorReward: true, witnessVote: true, witnessCancelVote: true)
                return self.setPushNotify(options: value.toParam())
            })
    }
    
    /// Turn off push notification
    public func pushNotifyOff() -> Completable {
        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.notifyPushOff(appProfileType: AppProfileType.golos)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIStatus>)
            .do(onSuccess: { _ in
                UserDefaults.standard.set(false, forKey: Config.currentUserPushNotificationOn)
            })
            .flatMapToCompletable()
    }
    
    /// Get options of push notify
    public func getPushNotify() -> Single<ResponseAPIGetOptions> {
        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard Config.currentUser?.id != nil else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let methodAPIType = MethodAPIType.getOptions
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    /// Turn specific notification types on or off
    public func setPushNotify(
        options: RequestParameterAPI.NoticeOptions,
        type: NoticeType = .push,
        appProfileType: AppProfileType = .golos) -> Completable {
        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard Config.currentUser?.id != nil else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let methodAPIType = MethodAPIType.setNotice(options: options, type: type, appProfileType: appProfileType)
        
        return (Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIStatus>)
            .flatMapToCompletable()
    }
}

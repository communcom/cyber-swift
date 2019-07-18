//
//  RAM+Notifications.swift
//  CyberSwift
//
//  Created by Chung Tran on 19/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift

public enum NoticeType {
    case push
    case notify
}

extension Reactive where Base: RestAPIManager {
    /// Turn on push notification
    public func pushNotifyOn() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let token = UserDefaults.standard.value(forKey: "fcmToken") as? String else {
            return .error(ErrorAPI.requestFailed(message: "Token not found"))
        }
        
        let methodAPIType = MethodAPIType.notifyPushOn(fcmToken: token, appProfileType: AppProfileType.golos)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .map {result in
                guard let result = (result as? ResponseAPINotifyPushOnResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
            .log(method: "push.notifyOn")
            .do(onSuccess: { _ in
                UserDefaults.standard.set(true, forKey: Config.currentUserPushNotificationOn)
            })
            .flatMapToCompletable()
    }
    
    /// Turn off push notification
    public func pushNotifyOff() -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let methodAPIType = MethodAPIType.notifyPushOff(appProfileType: AppProfileType.golos)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .map {result in
                guard let result = (result as? ResponseAPINotifyPushOffResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
            .log(method: "push.notifyOff")
            .do(onSuccess: { _ in
                UserDefaults.standard.set(false, forKey: Config.currentUserPushNotificationOn)
            })
            .flatMapToCompletable()
    }
    
    /// Get options of push notify
    public func getPushNotify() -> Single<ResponseAPIGetOptions> {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard Config.currentUser?.id != nil else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let methodAPIType = MethodAPIType.getOptions
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .log(method: "options.get")
            .map {result in
                guard let result = (result as? ResponseAPIGetOptionsResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
            
    }
    
    /// Turn specific notification types on or off
    public func setPushNotify(
        options: RequestParameterAPI.NoticeOptions,
        type: NoticeType = .push,
        appProfileType: AppProfileType = .cyber) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) {
            return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard Config.currentUser?.id != nil else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let methodAPIType = MethodAPIType.setNotice(options: options, type: type, appProfileType: appProfileType)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
            .map {result in
                guard let result = (result as? ResponseAPISetOptionsNoticeResult)?.result else {
                    throw ErrorAPI.unknown
                }
                return result
            }
            .log(method: "options.set")
            .flatMapToCompletable()
    }
}

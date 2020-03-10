//
//  NotificationsManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class NotificationsManager {
    // MARK: - Nested type
    enum Event: String {
        case statusUpdated = "notifications.statusUpdated"
        case newNotification = "notifications.newNotification"
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public let unseenNotificationsRelay = BehaviorRelay<UInt64>(value: 0)
    public let newNotificationsRelay = BehaviorRelay<[ResponseAPIGetNotificationItem]>(value: [])
    
    // MARK: - Singleton
    public static let shared = NotificationsManager()
    private init() {
        bind()
    }
    
    // MARK: - Methods
    private func bind() {
        catchEvent(.statusUpdated, objectType: ResponseAPINotificationsStatusUpdated.self)
            .subscribe(onNext: { (status) in
                self.unseenNotificationsRelay.accept(status.unseenCount)
            })
            .disposed(by: disposeBag)
        
        catchEvent(.newNotification, objectType: ResponseAPIGetNotificationItem.self)
            .subscribe(onNext: { (item) in
               var newNotifications = self.newNotificationsRelay.value
               newNotifications.joinUnique([item])
               self.newNotificationsRelay.accept(newNotifications.sortedByTimestamp)
            })
            .disposed(by: disposeBag)
    }
    
    func flush() {
        newNotificationsRelay.accept([])
        unseenNotificationsRelay.accept(0)
    }
    
    // MARK: - Helpers
    private func catchEvent<T: Decodable>(_ event: Event, objectType: T.Type) -> Observable<T> {
        SocketManager.shared
            .catchEvent(event.rawValue, objectType: T.self)
    }
}

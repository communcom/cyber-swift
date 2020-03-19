//
//  AuthManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/6/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class AuthManager {
    // MARK: - Nested type
    public enum Status: Equatable {
        // login, register, boarding
        case initializing
        case registering(step: CurrentUserRegistrationStep)
        case boarding(step: CurrentUserSettingStep)
        
        // authorize after signing socket
        case authorizing
        
        // authorization completed
        case authorized
        
        // error
        case error(CMError)
    }
    
    // MARK: - Constants
    public static let minPasswordLength = 8
    public static let maxPasswordLength = 52
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public let status = BehaviorRelay<Status>(value: .initializing)
    public var isLoggedOut = false
    
    // MARK: - Singleton
    public static let shared = AuthManager()
    private init() {
        bind()
    }
    
    deinit {
        disconnect()
    }
    
    public func connect() {
        SocketManager.shared.connect()
    }
    
    public func disconnect() {
        SocketManager.shared.disconnect()
    }
    
    private func bind() {
        SocketManager.shared.state
            .distinctUntilChanged()
            .subscribe(onNext: { (event) in
                Logger.log(message: "SocketManager.state = \(event)", event: .event)
                switch event {
                case .connecting:
                    // after logining, registering, boarding completed
                    self.status.accept(.authorizing)
                case .signed:
                    self.route()
                case .disconnected(let error):
                    self.status.accept(.error(.socketConnectionError(message: error?.localizedDescription)))
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
        
        status
            .subscribe(onNext: { (state) in
                Logger.log(message: "AuthManager.status = \(state)", event: .event)
            })
            .disposed(by: disposeBag)
    }
    
    private func route() {
        let step = KeychainManager.currentUser()?.registrationStep ?? .firstStep
        if step == .registered || step == .relogined {
            // If first setting is uncompleted
            let settingStep = KeychainManager.currentUser()?.settingStep ?? .backUpICloud
            if settingStep != .completed {
                self.status.accept(.boarding(step: settingStep))
                return
            } else {
                // after logining, registering, boarding completed
                self.status.accept(.authorizing)
                
                // authorizing
                RestAPIManager.instance.authorize()
                    .subscribe(onSuccess: { (_) in
                        self.deviceSetInfo()
                        self.status.accept(.authorized)
                        self.isLoggedOut = false
                    }) { (error) in
                        self.status.accept(.error(error.cmError))
                    }
                    .disposed(by: disposeBag)
            }
        } else {
            self.status.accept(.registering(step: step))
        }
    }
}

// MARK: - Helpers
extension AuthManager {
    public func logout() {
        // Reset FCM token
        RestAPIManager.instance.sendMessageIgnoreResponse(methodAPIType: .deviceResetFcmToken, authorizationRequired: false)
        
        // logout
        RestAPIManager.instance.sendMessageIgnoreResponse(methodAPIType: .logout, authorizationRequired: false)
        
        // Remove in keychain
        try! KeychainManager.deleteUser()
        
        // Remove UserDefaults
        UserDefaults.standard.set(nil, forKey: Config.currentUserAppLanguageKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserAvatarUrlKey)
        UserDefaults.standard.set(nil, forKey: Config.currentUserBiometryAuthEnabled)
        UserDefaults.standard.set(nil, forKey: Config.currentUserDidSubscribeToMoreThan3Communities)
        UserDefaults.standard.set(nil, forKey: Config.currentDeviceDidSendFCMToken)
        UserDefaults.standard.set(nil, forKey: Config.currentDeviceDidSetInfo)
        
        // Remove old notifications
        NotificationsManager.shared.flush()
        
        // Assign loggedout
        isLoggedOut = true
        
        // resign status
        status.accept(.initializing)
        
        // rerun socket
        SocketManager.shared.reset()
    }
    
    public func reload() {
        status.accept(.initializing)
        route()
    }
    
    fileprivate func deviceSetInfo() {
        // set info
        if !UserDefaults.standard.bool(forKey: Config.currentDeviceDidSetInfo) {
            let offset = -TimeZone.current.secondsFromGMT() / 60
            RestAPIManager.instance.deviceSetInfo(timeZoneOffset: offset)
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: Config.currentDeviceDidSetInfo)
                })
                .disposed(by: disposeBag)
        }
        
        // fcm token
        if !UserDefaults.standard.bool(forKey: Config.currentDeviceDidSendFCMToken)
        {
            UserDefaults.standard.rx.observe(String.self, Config.currentDeviceFcmTokenKey)
                .filter {$0 != nil}
                .map {$0!}
                .take(1)
                .asSingle()
                .flatMap {RestAPIManager.instance.deviceSetFcmToken($0)}
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: Config.currentDeviceDidSendFCMToken)
                })
                .disposed(by: disposeBag)
        }
    }
}

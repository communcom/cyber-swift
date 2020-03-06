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
        case disconnected(CMError?)
        case error(CMError)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public let status = BehaviorRelay<Status>(value: .initializing)
    
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
            .debounce(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (event) in
                switch event {
                case .connecting:
                    // after logining, registering, boarding completed
                    self.status.accept(.authorizing)
                case .signed:
                    self.route()
                case .disconnected(let error):
                    self.status.accept(.disconnected(error))
                default:
                    return
                }
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
    public func reload() {
        self.status.accept(.initializing)
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

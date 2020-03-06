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
        case authorizing
        case boarding(step: CurrentUserSettingStep)
        case authorized
        case registering(step: CurrentUserRegistrationStep)
        case authorizingError(error: CMError)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    public let status = BehaviorRelay<Status>(value: .authorizing)
    
    // MARK: - Singleton
    public static let shared = AuthManager()
    private init() {
        bind()
    }
    
    private func bind() {
        SocketManager.shared.state
            .debounce(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (event) in
                switch event {
                case .signed:
                    self.authorize()
                case .disconnected(let error):
                    self.status.accept(.authorizingError(error: error))
                default:
                    return
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func authorize() {
        let step = KeychainManager.currentUser()?.registrationStep ?? .firstStep
        if step == .registered || step == .relogined {
            // If first setting is uncompleted
            let settingStep = KeychainManager.currentUser()?.settingStep ?? .backUpICloud
            if settingStep != .completed {
                self.status.accept(.boarding(step: settingStep))
                return
            } else {
                RestAPIManager.instance.authorize()
                    .subscribe(onSuccess: { (_) in
                        self.deviceSetInfo()
                        self.status.accept(.authorized)
                    }) { (error) in
                        self.status.accept(.authorizingError(error: error.cmError))
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
    public func forceReAuthorize() {
        self.status.accept(.authorizing)
        authorize()
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

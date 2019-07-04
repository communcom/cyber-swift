//
//  iCloudManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public struct iCloudManager {
    public static func saveUser() {
        guard let user = Config.currentUser else {
            return
        }
        
        let keyStore = NSUbiquitousKeyValueStore()
        keyStore.set(user.id, forKey: Config.currentUserIDKey)
        keyStore.set(user.name, forKey: Config.currentUserNameKey)
        
        keyStore.set(user.registrationStep, forKey: Config.registrationStepKey)
        keyStore.set(user.phoneNumber, forKey: Config.registrationUserPhoneKey)
        keyStore.set(user.smsCode, forKey: Config.registrationSmsCodeKey)
        keyStore.set(user.smsNextRetry, forKey: Config.registrationSmsNextRetryKey)
        
        keyStore.set(user.memoKeys?.privateKey, forKey: Config.currentUserPrivateMemoKey)
        keyStore.set(user.memoKeys?.publicKey, forKey: Config.currentUserPublickMemoKey)
        
        keyStore.set(user.ownerKeys?.privateKey, forKey: Config.currentUserPrivateOwnerKey)
        keyStore.set(user.ownerKeys?.publicKey, forKey: Config.currentUserPublicOwnerKey)
        
        keyStore.set(user.postingKeys?.privateKey, forKey: Config.currentUserPrivatePostingKey)
        keyStore.set(user.postingKeys?.publicKey, forKey: Config.currentUserPublicPostingKey)
        
        keyStore.set(user.activeKeys?.privateKey, forKey: Config.currentUserPrivateActiveKey)
        keyStore.set(user.activeKeys?.publicKey, forKey: Config.currentUserPublicActiveKey)
    }
    
    public static func deleteUser() {
        // TODO: Remove from iCloud
    }
}

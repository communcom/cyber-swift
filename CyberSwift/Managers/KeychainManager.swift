//
//  KeychainManager.swift
//  CyberSwift
//
//  Created by msm72 on 22.05.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import Locksmith
import Foundation

public class KeychainManager {
    private static let communService = LocksmithDefaultService
    
    // MARK: - Deleting
    /// Delete stored data from Keychain
    public static func deleteUser() throws {
        try Locksmith.deleteDataForUserAccount(userAccount: Config.currentUserIDKey)
    }
    
    // MARK: - Retrieving
    /// Load data user's data
    public static func currentUser() -> CurrentUser? {
        // Non-optional properties
        guard let data = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey)
        else {
            return nil
        }
        
        // Optional properties
        let id = data[Config.currentUserIDKey] as? String
        let name = data[Config.currentUserNameKey] as? String
        
        let registrationStep = data[Config.registrationStepKey] as? String
        let phone = data[Config.registrationUserPhoneKey] as? String
        let smsCode = data[Config.registrationSmsCodeKey] as? UInt64
        let smsRetryCode = data[Config.registrationSmsNextRetryKey] as? String
        
        let memoKeys = UserKeys(
            privateKey: data[Config.currentUserPrivateMemoKey] as? String,
            publicKey: data[Config.currentUserPublickMemoKey] as? String)
        
        let ownerKeys = UserKeys(
            privateKey: data[Config.currentUserPrivateOwnerKey] as? String,
            publicKey: data[Config.currentUserPublicOwnerKey] as? String)
        
        let postingKeys = UserKeys(
            privateKey: data[Config.currentUserPrivatePostingKey] as? String,
            publicKey: data[Config.currentUserPublicPostingKey] as? String)
        
        let activeKeys = UserKeys(
            privateKey: data[Config.currentUserPrivateActiveKey] as? String,
            publicKey: data[Config.currentUserPublicActiveKey] as? String)
        
        
        return CurrentUser(
            id: id,
            name: name,
            
            registrationStep: registrationStep,
            phoneNumber: phone,
            smsCode: smsCode,
            smsNextRetry: smsRetryCode,
            
            memoKeys: memoKeys,
            ownerKeys: ownerKeys,
            activeKeys: activeKeys,
            postingKeys: postingKeys
        )
    }
    
    // MARK: - Saving
    /// Save login data to Keychain
    public static func save(data: [String: Any]) throws {
        try Locksmith.updateData(data: data, forUserAccount: Config.currentUserIDKey)
    }
}

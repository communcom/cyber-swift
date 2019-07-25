//
//  KeychainManager.swift
//  CyberSwift
//
//  Created by msm72 on 22.05.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import Locksmith
import Foundation
import RxCocoa

public class KeychainManager {
    private static let communService = "io.commun.eos.ios"
    
    // MARK: - Deleting
    /// Delete stored data from Keychain
    public static func deleteUser() throws {
        try Locksmith.deleteDataForUserAccount(userAccount: Config.currentUserIDKey, inService: communService)
    }
    
    // MARK: - Retrieving
    /// Load data user's data
    public static func currentUser() -> CurrentUser? {
        // Non-optional properties
        guard let data = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey, inService: communService)
        else {
            return nil
        }
        
        // Optional properties
        let id = data[Config.currentUserIDKey] as? String
        let name = data[Config.currentUserNameKey] as? String
        
        let masterKey = data[Config.currentUserMasterKey] as? String
        
        let registrationStep = CurrentUserRegistrationStep(rawValue:
            data[Config.registrationStepKey] as? String ?? "firstStep")!
        
        let phone = data[Config.registrationUserPhoneKey] as? String
        let smsCode = data[Config.registrationSmsCodeKey] as? UInt64
        let smsRetryCode = data[Config.registrationSmsNextRetryKey] as? String
        
        let settingStep = data[Config.settingStepKey] as? String
        let passcode = data[Config.currentUserPasscodeKey] as? String
        
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
            masterKey: masterKey,
            registrationStep: registrationStep,
            phoneNumber: phone,
            smsCode: smsCode,
            smsNextRetry: smsRetryCode,
            settingStep: settingStep != nil ? CurrentUserSettingStep(rawValue: settingStep!) : nil,
            passcode: passcode,
            memoKeys: memoKeys,
            ownerKeys: ownerKeys,
            activeKeys: activeKeys,
            postingKeys: postingKeys)
    }
    
    // MARK: - Saving
    /// Save login data to Keychain
    public static func save(data: [String: Any]) throws {
        var dataToSave = [String: Any]()
        if let currentData = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey, inService: communService) {
            dataToSave = currentData
        }
        
        for (key, value) in data {
            dataToSave[key] = value
        }
        
        try Locksmith.updateData(data: dataToSave, forUserAccount: Config.currentUserIDKey, inService: communService)
    }
    
    static func save(userkeys: [String: UserKeys]) throws {
        try save(data: [
            Config.currentUserPublicOwnerKey: userkeys["owner"]!.publicKey!,
            Config.currentUserPrivateOwnerKey: userkeys["owner"]!.privateKey!,
            Config.currentUserPublicActiveKey: userkeys["active"]!.publicKey!,
            Config.currentUserPrivateActiveKey: userkeys["active"]!.privateKey!,
            Config.currentUserPublicPostingKey: userkeys["posting"]!.publicKey!,
            Config.currentUserPrivatePostingKey: userkeys["posting"]!.privateKey!,
            Config.currentUserPublickMemoKey: userkeys["memo"]!.publicKey!,
            Config.currentUserPrivateMemoKey: userkeys["memo"]!.privateKey!
        ])
    }
}

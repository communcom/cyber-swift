//
//  KeychainManager.swift
//  CyberSwift
//
//  Created by msm72 on 22.05.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import Locksmith
import Foundation
import RxCocoa
import Crashlytics

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

        let provider = data[Config.currentUserProviderKey] as? String
        let identity = data[Config.currentUserIdentityKey] as? String

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
            identity: identity,
            provider: provider,
            smsCode: smsCode,
            smsNextRetry: smsRetryCode,
            settingStep: settingStep != nil ? CurrentUserSettingStep(rawValue: settingStep!) : nil,
            passcode: passcode,
            memoKeys: memoKeys,
            ownerKeys: ownerKeys,
            activeKeys: activeKeys,
            postingKeys: postingKeys)
    }
    
    static var currentDeviceId: String? {
        return Locksmith.loadDataForUserAccount(userAccount: Config.currentDeviceIdKey, inService: communService)?[Config.currentDeviceIdKey] as? String
    }
    
    // MARK: - Saving
    /// Save login data to Keychain
    public static func save(_ data: [String: Any], account: String = Config.currentUserIDKey) throws {
        var dataToSave = [String: Any]()
        if let currentData = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey, inService: communService) {
            dataToSave = currentData
        }
        
        for (key, value) in data {
            dataToSave[key] = value
        }
        
        try Locksmith.updateData(data: dataToSave, forUserAccount: account, inService: communService)
    }
    
    static func save(userkeys: [String: UserKeys]) throws {
        try save([
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
    
    // MARK: - Creating
    /// Create unique device id
    public static func createDeviceId() {
        // migration: move deviceId from currentUserAccount to its separate account
        moveDeviceIdToNewAccount()
        
        // Create deviceId if not exists
        if KeychainManager.currentDeviceId == nil {
            let id = UUID().uuidString + "." + "\(Date().timeIntervalSince1970)"
            do {
                try KeychainManager.save([Config.currentDeviceIdKey: id], account: Config.currentDeviceIdKey)
            } catch {
                ErrorLogger.shared.recordError(error, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
                Logger.log(message: error.localizedDescription, event: .debug)
            }
        }
    }
    
    fileprivate static func moveDeviceIdToNewAccount() {
        // Migration: save deviceId sepratately from user's data in key chain
        let deviceIdMigrationKey = "Keychain.deviceIdMigrationKey"
        if !UserDefaults.standard.bool(forKey: deviceIdMigrationKey)
        {
            // if old data saved in currentUserIDKey's account
            if let currentKey = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey, inService: communService)?[Config.currentDeviceIdKey] as? String
            {
                // save old data into separate account
                do {
                    try Locksmith.saveData(data: [Config.currentDeviceIdKey: currentKey], forUserAccount: Config.currentDeviceIdKey)
                } catch {
                    ErrorLogger.shared.recordError(error, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
                }
            }
            UserDefaults.standard.set(true, forKey: deviceIdMigrationKey)
        }
    }
}

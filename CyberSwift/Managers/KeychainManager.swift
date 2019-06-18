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
    /// Delete stored data from Keychain
    public static func deleteData(forUserNickName userNickName: String, withKey key: String) -> Bool {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userNickName, inService: key)
            Logger.log(message: "Successfully delete User data by key from Keychain.", event: .severe)
            return true
        } catch {
            Logger.log(message: "Error delete User data by key from Keychain.", event: .error)
            return false
        }
    }
    
    public static func deleteAllData(forUserNickName userNickName: String) -> Bool {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userNickName)
            Logger.log(message: "Successfully delete all User data from Keychain.", event: .severe)
            return true
        } catch {
            Logger.log(message: "Delete error all User data from Keychain.", event: .error)
            return false
        }
    }
    
    
    /// Load data from Keychain
    public static func loadKey(type: String, forUserNickName userNickName: String) -> String? {
        var resultKey: String?
        
        if let data = Locksmith.loadDataForUserAccount(userAccount: userNickName, inService: type) {
            resultKey = data[Config.currentUserPublicActiveKey] as? String
        }
        
        return resultKey
    }
    
    public static func loadData(byUserID userID: String, withKey key: String) -> [String: Any]? {
        return Locksmith.loadDataForUserAccount(userAccount: userID, inService: key)
    }
    
    public static func loadAllData(byUserID userID: String) -> [String: Any]? {
        return Locksmith.loadDataForUserAccount(userAccount: userID)
    }
    
    public static func loadAllData(byUserPhone userPhone: String) -> [String: Any]? {
        return Locksmith.loadDataForUserAccount(userAccount: userPhone, inService: userPhone)
        
    }
    
    
    /// Save login data to Keychain
    public static func save(keys: [UserKeys], userID: String, userName: String) -> Bool {
        var result: Bool = true
        
        let ownerUserKeys   =   keys.first(where: { $0.type == "owner" })
        let activeUserKeys  =   keys.first(where: { $0.type == "active" })
        let postingUserKeys =   keys.first(where: { $0.type == "posting" })
        let memoUserKeys    =   keys.first(where: { $0.type == "memo" })
        
        Config.currentUser  =   (id: userID, name: userName, activeKey: activeUserKeys!.privateKey)
        
        result = result && self.save(data: [Config.currentUserPrivateMemoKey: memoUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublickMemoKey: memoUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivateOwnerKey: ownerUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublickMemoKey: ownerUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivateActiveKey: activeUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublicActiveKey: activeUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivatePostingKey: postingUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublicPostingKey: postingUserKeys!.publicKey], userID: userID)
        
        return result
    }
    
    public static func save(data: [String: Any], userID: String) -> Bool {
        let keyData = data.keys.first ?? "XXX"
        
        do {
            if Locksmith.loadDataForUserAccount(userAccount: userID, inService: keyData) == nil {
                try Locksmith.saveData(data: data, forUserAccount: userID, inService: keyData)
            }
                
            else {
                try Locksmith.updateData(data: data, forUserAccount: userID, inService: keyData)
            }
            
            Logger.log(message: "Successfully save User data to Keychain.", event: .severe)
            return true
        } catch {
            Logger.log(message: "Error save User data to Keychain.", event: .error)
            return false
        }
    }
    
    public static func save(data: [String: Any], userPhone: String) -> Bool {
        do {
            if Locksmith.loadDataForUserAccount(userAccount: userPhone, inService: userPhone) == nil {
                try Locksmith.saveData(data: data, forUserAccount: userPhone, inService: userPhone)
            }
                
            else {
                try Locksmith.updateData(data: data, forUserAccount: userPhone, inService: userPhone)
            }
            
            Logger.log(message: "Successfully save User data to Keychain.", event: .severe)
            return true
        } catch {
            Logger.log(message: "Error save User data to Keychain.", event: .error)
            return false
        }
    }
}

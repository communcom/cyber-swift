//
//  KeychainManager.swift
//  CyberSwift
//
//  Created by msm72 on 22.05.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import Locksmith
import PDFReader
import Foundation

public class KeychainManager {
    /// Delete stored data from Keychain
    public static func deleteData(forUserNickName userNickName: String, withKey key: String = LocksmithDefaultService) -> Bool {
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
        let ownerUserKeys   =   keys.first(where: { $0.type == "owner" })
        let activeUserKeys  =   keys.first(where: { $0.type == "active" })
        let postingUserKeys =   keys.first(where: { $0.type == "posting" })
        let memoUserKeys    =   keys.first(where: { $0.type == "memo" })
        
        var result: Bool    =   self.save(data:     [
                                                        Config.currentUserIDKey:            userID,
                                                        Config.currentUserNameKey:          userName,
                                                        Config.currentUserPublicActiveKey:  activeUserKeys!.privateKey
                                                    ],
                                          userID:   Config.currentUserIDKey)
        
        result = result && self.save(data: [Config.currentUserPrivateMemoKey: memoUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublickMemoKey: memoUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivateOwnerKey: ownerUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublickMemoKey: ownerUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivateActiveKey: activeUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublicActiveKey: activeUserKeys!.publicKey], userID: userID)
        
        result = result && self.save(data: [Config.currentUserPrivatePostingKey: postingUserKeys!.privateKey], userID: userID)
        result = result && self.save(data: [Config.currentUserPublicPostingKey: postingUserKeys!.publicKey], userID: userID)
        
        if result {
            KeychainManager.createPDFFile(id:           userID,
                                          name:         userName,
                                          memo:         memoUserKeys!.privateKey,
                                          owner:        ownerUserKeys!.privateKey,
                                          active:       activeUserKeys!.privateKey,
                                          posting:      postingUserKeys!.privateKey)
        }

        return result
    }
    
    public static func save(data: [String: Any], userID: String) -> Bool {
        do {
            if Locksmith.loadDataForUserAccount(userAccount: userID, inService: LocksmithDefaultService) == nil {
                try Locksmith.saveData(data: data, forUserAccount: userID, inService: LocksmithDefaultService)
            }
                
            else {
                try Locksmith.updateData(data: data, forUserAccount: userID, inService: LocksmithDefaultService)
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

    
    // MASK: - PDFKit
    public static func createPDFFile(id: String, name: String, memo: String, owner: String, active: String, posting: String) {
        let documentsDirectory  =   NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath            =   (documentsDirectory as NSString).appendingPathComponent("userKeys.pdf") as String
        
        let pdfTitle            =   String(format: "id:\n\"%@\"\n\nname:\n\"%@\"\n\nmemo key:\n\"%@\"\n\nowner key:\n\"%@\"\n\nactive key:\n\"%@\"\n\nposting key:\n\"%@\"", id, name, memo, owner, active, posting)
        
        let pdfMetadata         =   [
            // The name of the application creating the PDF.
            kCGPDFContextCreator: "Commun iOS App",
            
            // The name of the PDF's author.
            kCGPDFContextAuthor: "CyberSwift",
            
            // The title of the PDF.
            kCGPDFContextTitle: "User keys",
            
            // Encrypts the document with the value as the owner password. Used to enable/disable different permissions.
            // kCGPDFContextOwnerPassword: "myPassword123"
        ]
        
        // Creates a new PDF file at the specified path.
        UIGraphicsBeginPDFContextToFile(filePath, CGRect.zero, pdfMetadata)
        
        // Creates a new page in the current PDF context.
        UIGraphicsBeginPDFPage()
        
        // Default size of the page is 612x792.
        let pageSize    =   UIGraphicsGetPDFContextBounds().size
        let font        =   UIFont.preferredFont(forTextStyle: .largeTitle)
        
        // Let's draw the title of the PDF on top of the page.
        let attributedPDFTitle  =   NSAttributedString(string: pdfTitle, attributes: [NSAttributedString.Key.font: font])
        let stringRect          =   CGRect(x: 20.0, y: 0.0, width: pageSize.width - 40, height: pageSize.height - 20)
        
        attributedPDFTitle.draw(in: stringRect)
        
        // Closes the current PDF context and ends writing to the file.
        UIGraphicsEndPDFContext()
    }
    
    public static func loadPDFDocument() -> PDFDocument? {
        let documentsDirectory  =   NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath            =   (documentsDirectory as NSString).appendingPathComponent("userKeys.pdf") as String
        
        return PDFDocument(url: URL(fileURLWithPath: filePath))
    }
    
    public static func deletePDFDocument() {
        let documentsDirectory  =   NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath            =   (documentsDirectory as NSString).appendingPathComponent("userKeys.pdf") as String
        
        do {
            try FileManager.default.removeItem(atPath: filePath)
            
            if let pdfDocument = KeychainManager.loadPDFDocument() {
                Logger.log(message: pdfDocument.fileName, event: .debug)
            } else {
                Logger.log(message: "PDF-file deleted!!!", event: .severe)
            }
        } catch {
            Logger.log(message: error.localizedDescription, event: .error)
        }
    }
}

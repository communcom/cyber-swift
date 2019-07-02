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
    private static let communService = LocksmithDefaultService
    
    // MARK: - Deleting
    /// Delete stored data from Keychain
    public static func deleteUser() throws {
        try Locksmith.deleteDataForUserAccount(userAccount: Config.currentUserIDKey)
        if let phone = UserDefaults.standard.string(forKey: Config.registrationUserPhoneKey) {
            try? Locksmith.deleteDataForUserAccount(userAccount: phone, inService: phone)
        }
    }
    
    // MARK: - Retrieving
    /// Load data from loggedInUser
    public static func currentUser() -> CurrentUser? {
        // Non-optional properties
        guard let data = Locksmith.loadDataForUserAccount(userAccount: Config.currentUserIDKey),
            let id = data[Config.currentUserIDKey] as? String,
            let activeKey = data[Config.currentUserPublicActiveKey] as? String
        else {
            return nil
        }
        
        // Optional properties
        let name = data[Config.currentUserNameKey] as? String
        let registrationStep = data[Config.registrationStepKey] as? String
        let phone = data[Config.registrationUserPhoneKey] as? String
        let smsCode = data[Config.registrationSmsCodeKey] as? String
        let smsRetryCode = data[Config.registrationSmsNextRetryKey] as? String
        
        return CurrentUser(
            id: id,
            name: name,
            activeKey: activeKey,
            
            registrationStep: registrationStep,
            phoneNumber: phone,
            smsCode: smsCode,
            smsNextRetry: smsRetryCode
        )
    }
    
    // MARK: - Saving
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
            
            // Auth new account
            DispatchQueue.main.async {
                RestAPIManager.instance.authorize(userID:               Config.currentUser.id!,
                                                  userActiveKey:        Config.currentUser.activeKey!,
                                                  responseHandling:     { response in
                },
                                                  errorHandling:        { errorAPI in
                })
            }
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

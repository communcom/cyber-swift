//
//  PDFManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 02/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import PDFReader

struct PDFManager {
    public static func createPDFFile() {
        guard let user = KeychainManager.currentUser() else {
            return
        }
        
        let documentsDirectory  =   NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath            =   (documentsDirectory as NSString).appendingPathComponent("userKeys.pdf") as String
        
        let pdfTitle            =   String(format: "id:\n\"%@\"\n\nname:\n\"%@\"\n\nmemo key:\n\"%@\"\n\nowner key:\n\"%@\"\n\nactive key:\n\"%@\"\n\nposting key:\n\"%@\"", user.id, user.name ?? "", user.memoKeys?.privateKey ?? "", user.ownerKeys?.privateKey ?? "", user.activeKeys?.privateKey ?? "", user.postingKeys?.privateKey ?? "")
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
            
            if let pdfDocument = loadPDFDocument() {
                Logger.log(message: pdfDocument.fileName, event: .debug)
            } else {
                Logger.log(message: "PDF-file deleted!!!", event: .severe)
            }
        } catch {
            Logger.log(message: error.localizedDescription, event: .error)
        }
    }
}

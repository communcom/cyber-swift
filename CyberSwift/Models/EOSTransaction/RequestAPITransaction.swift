//
//  RequestAPITransaction.swift
//  CyberSwift
//
//  Created by Chung Tran on 7/31/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public struct RequestAPITransaction: Encodable {
    public let signatures: [String]
    public let serializedTransaction: String
    
    func convertToJSON() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
    }
}

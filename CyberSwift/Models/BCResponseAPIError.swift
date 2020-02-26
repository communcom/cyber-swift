//
//  BCResponseAPIError.swift
//  CyberSwift
//
//  Created by Chung Tran on 25/06/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

public struct BCResponseAPIErrorResult: Decodable {
    // MARK: - In work
    public let code: Int64
    public let message: String
    public let error: BCResponseAPIError
    
    public var realMessage: String {
        error.details.first?.message.replacingOccurrences(of: "assertion failure with message: ", with: "") ?? "unknown"
    }
}

public struct BCResponseAPIError: Decodable {
    public let code: Int64
    public let name: String
    public let what: String
    public let details: [BCResponseAPIErrorDetail]
}

public struct BCResponseAPIErrorDetail: Decodable {
    public let message: String
    public let file: String
    public let line_number: Int64
    public let method: String
}

//
//  RequestAPITransaction.swift
//  CyberSwift
//
//  Created by Chung Tran on 7/31/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

public struct RequestAPITransaction: Encodable {
    public let signatures: [String]
    public let serializedTransaction: String
}

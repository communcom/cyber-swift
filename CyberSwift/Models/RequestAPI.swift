//
//  RequestAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation

public struct RequestAPI: Codable {
    public let id: Int
    public let method: String
    public let jsonrpc: String
    public let user: String?
    public let params: [String: String]
}

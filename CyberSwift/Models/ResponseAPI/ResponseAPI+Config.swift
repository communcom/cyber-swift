//
//  ResponseAPI+Config.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIGetConfig: Codable, Equatable {
    public let features: ResponseAPIGetConfigFeatures?
    public let domain: String?
    public let ftueCommunityBonus: UInt?
}

public struct ResponseAPIGetConfigFeatures: Codable, Equatable {
    public let ftueCommunityBunus: Bool
}

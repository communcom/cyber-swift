//
//  ResponseAPI+Config.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public struct ResponseAPIGetConfig: Codable, Equatable {
    let features: ResponseAPIGetConfigFeatures?
    let domain: String?
    let ftueCommunityBonus: UInt
}

public struct ResponseAPIGetConfigFeatures: Codable, Equatable {
    let ftueCommunityBunus: Bool
}

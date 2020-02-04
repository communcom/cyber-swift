//
//  ResponseAPI+Rewards.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIRewardsGetStateBulk: Decodable {
    public let mosaics: [ResponseAPIRewardsGetStateBulkMosaic]
}

public struct ResponseAPIRewardsGetStateBulkMosaic: Decodable, Equatable {
    public let topCount: UInt64
    public let collectionEnd: String
    public let reward: String
    public let isClosed: Bool
    public let contentId: ResponseAPIContentId
}

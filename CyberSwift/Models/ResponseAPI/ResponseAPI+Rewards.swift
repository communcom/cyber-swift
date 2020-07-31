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
    public let topCount: Int64
    public let collectionEnd: String
    public let reward: String?
    public let displayReward: String?
    public let isClosed: Bool
    public let contentId: ResponseAPIContentId
    public let convertedReward: ResponseAPIRewardsGetStateBulkMosaicConvertedReward?
    
    public var isRewarded: Bool {
        topCount > 0 && rewardDouble > 0
    }
    
    public var rewardDouble: Double {
        guard let string = (displayReward ?? reward)?.components(separatedBy: " ").first,
            let double = Double(string)
        else {
            return 0
        }
        return double
    }
}

public struct ResponseAPIRewardsGetStateBulkMosaicConvertedReward: Decodable, Equatable {
    public let usd: String?
    public let cmn: String?
}

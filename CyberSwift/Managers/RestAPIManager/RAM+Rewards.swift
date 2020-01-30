//
//  RAM+Rewards.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/30/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    func rewardsGetStateBulk(posts: [RequestAPIContentId]) -> Single<ResponseAPIRewardsGetStateBulk> {
        let methodAPIType = MethodAPIType.rewardsGetStateBulk(posts: posts)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

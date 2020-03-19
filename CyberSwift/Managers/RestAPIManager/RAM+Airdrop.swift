//
//  RAM+Airdrop.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/19/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getAirdrop(communityId: String) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.getAirdrop(communityId: communityId)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

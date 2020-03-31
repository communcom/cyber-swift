//
//  RAM+Referral.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/31/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getReferralUsers(
        offset: UInt                    = 0,
        limit: UInt                     = UInt(Config.paginationLimit)
    ) -> Single<ResponseAPIContentGetReferralUsers> {
        let methodAPIType = MethodAPIType.getReferralUsers(limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func appendReferralParent(referralId: String) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.appendReferralParent(refferalId: referralId, phone: Config.currentUser?.phoneNumber, identity: Config.currentUser?.identity, email: Config.currentUser?.email, userId: Config.currentUser?.id)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

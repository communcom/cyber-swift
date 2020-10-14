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
        offset: UInt = 0,
        limit: UInt = UInt(Config.paginationLimit)
    ) -> Single<ResponseAPIContentGetReferralUsers> {
        executeGetRequest(methodGroup: .content, methodName: "getReferralUsers", params: ["limit": limit, "offset": offset])
    }
    
    public func appendReferralParent(referralId: String) -> Single<ResponseAPIStatus> {
        var params: [String: Encodable] = ["referralId": referralId]
        params["phone"] = Config.currentUser?.phoneNumber
        params["identity"] = Config.currentUser?.identity
        params["email"] = Config.currentUser?.email
        params["userId"] = Config.currentUser?.id
        return executeGetRequest(methodGroup: .registration, methodName: "appendReferralParent", params: params)
    }
}

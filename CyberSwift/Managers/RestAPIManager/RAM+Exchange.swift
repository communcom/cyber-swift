//
//  RAM+Exchange.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getCurrenciesFull() -> Single<[ResponseAPIGetCurrency]> {
        let methodAPIType = MethodAPIType.getCurrenciesFull
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func exchangeGetMinMaxAmount(
        from: String,
        to: String
    ) -> Single<ResponseAPIGetMinMaxAmount> {
        let methodAPIType = MethodAPIType.getMinMaxAmount(from: from, to: to)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getExchangeAmount(
        from: String,
        to: String = "CMN",
        amount: Double
    ) -> Single<String> {
        let methodAPIType = MethodAPIType.getExchangeAmount(from: from, to: to, amount: amount)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func createTransaction(
        from: String,
        address: String,
        amount: String,
        extraId: String? = nil,
        refundAddress: String? = nil,
        refundExtraId: String? = nil
    ) -> Single<ResponseAPICreateTransaction> {
        let methodAPIType = MethodAPIType.createTransaction(from: from, address: address, amount: amount, extraId: extraId, refundAddress: refundAddress, refundExtraId: refundExtraId)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

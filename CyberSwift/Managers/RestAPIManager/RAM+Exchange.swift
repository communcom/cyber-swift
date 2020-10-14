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
        executeGetRequest(methodGroup: .exchange, methodName: "getCurrenciesFull", params: [:])
    }
    
    public func exchangeGetMinMaxAmount(
        from: String,
        to: String
    ) -> Single<ResponseAPIGetMinMaxAmount> {
        executeGetRequest(methodGroup: .exchange, methodName: "getMinMaxAmount", params: ["from": from, "to": to])
    }
    
    public func getExchangeAmount(
        from: String,
        to: String = "CMN",
        amount: Double
    ) -> Single<String> {
        executeGetRequest(methodGroup: .exchange, methodName: "getExchangeAmount", params: ["from": from, "to": to, "amount": amount])
    }
    
    public func createTransaction(
        from: String,
        address: String,
        amount: String,
        extraId: String? = nil,
        refundAddress: String? = nil,
        refundExtraId: String? = nil
    ) -> Single<ResponseAPICreateTransaction> {
        var parameters = [String: Encodable]()
        parameters["from"] = from
        parameters["address"] = address
        parameters["amount"] = amount
        parameters["extraId"] = extraId
        parameters["refundAddress"] = refundAddress
        parameters["refundExtraId"] = refundExtraId
        return executeGetRequest(methodGroup: .exchange, methodName: "createTransaction", params: parameters)
    }
}

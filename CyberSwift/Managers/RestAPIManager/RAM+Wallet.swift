//
//  RAM+Wallet.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getTransferHistory(
        userId: String? = nil,
        direction: String = "all",
        transferType: String? = "all",
        symbol: String? = nil,
        reward: String? = "all",
        donation: String? = "all",
        claim: String? = "all",
        holdType: String? = "like",
        offset: UInt = 0,
        limit: UInt = 20
    ) -> Single<ResponseAPIWalletGetTransferHistory> {
        var parameters = [String: Encodable]()
        parameters["userId"] = userId
        parameters["direction"] = direction
        parameters["transferType"] = transferType
        parameters["symbol"] = symbol
        parameters["rewards"] = reward
        parameters["claim"] = claim
        parameters["donation"] = donation
        parameters["holdType"] = holdType
        parameters["offset"] = offset
        parameters["limit"] = limit
        return executeGetRequest(methodGroup: .wallet, methodName: "getTransferHistory", params: parameters)
    }
    
    public func getBalance(
        userId: String? = nil,
        retried: Bool = false
    ) -> Single<ResponseAPIWalletGetBalances> {
        (executeGetRequest(methodGroup: .wallet, methodName: "getBalance", params: ["userId": userId]) as Single<ResponseAPIWalletGetBalances>)
            .flatMap { result -> Single<ResponseAPIWalletGetBalances> in
                if userId != Config.currentUser?.id || retried {return .just(result)}

//                 open balance when CMN is missing
                var result = result
                if let cmnIndex = result.balances.firstIndex(where: { $0.symbol == Config.defaultSymbol }) {
                    if cmnIndex > 0 {
                        let element = result.balances[cmnIndex]
                        result.balances.remove(at: cmnIndex)
                        result.balances.insert(element, at: 0)
                    }
                } else {
                    BlockchainManager.instance.openCMNBalance().subscribe().dispose()
                    result.balances.insert(ResponseAPIWalletGetBalance(symbol: Config.defaultSymbol, balance: "0", logo: nil, name: nil, frozen: nil, price: nil), at: 0)
                }
                
                return .just(result)
            }
    }
    
    public func getBuyPrice(
        symbol: String,
        quantity: String,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIWalletGetPrice> {
        (executeGetRequest(methodGroup: .wallet, methodName: "getBuyPrice", params: ["pointSymbol": symbol, "quantity": quantity], authorizationRequired: authorizationRequired) as Single<ResponseAPIWalletGetPrice>)
            .map { result in
                var result = result
                result.symbol = symbol
                result.quantity = quantity
                return result
            }
    }
    
    public func getSellPrice(
        quantity: String
    ) -> Single<ResponseAPIWalletGetPrice> {
        (executeGetRequest(methodGroup: .wallet, methodName: "getSellPrice", params: ["quantity": quantity]) as Single<ResponseAPIWalletGetPrice>)
            .map { result in
                var result = result
                result.quantity = quantity
                return result
            }
    }
    
    // MARK: - Rewards
    public func rewardsGetStateBulk(posts: [RequestAPIContentId]) -> Single<ResponseAPIRewardsGetStateBulk> {
        executeGetRequest(methodGroup: .rewards, methodName: "getStateBulk", params: ["posts": posts], authorizationRequired: false)
    }
    
    // MARK: - Donations
    public func getDonationsBulk(posts: [RequestAPIContentId]) -> Single<ResponseAPIWalletGetDonationsBulk> {
        executeGetRequest(methodGroup: .wallet, methodName: "getDonationsBulk", params: ["posts": posts], authorizationRequired: false)
    }
}

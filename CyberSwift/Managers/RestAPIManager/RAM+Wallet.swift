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
        transferType: String? = nil,
        symbol: String? = nil,
        reward: String? = nil,
        offset: UInt = 0,
        limit: UInt = 20
    ) -> Single<ResponseAPIWalletGetTransferHistory> {
        let methodAPIType = MethodAPIType.getTransferHistory(userId: userId, direction: direction, transferType: transferType, symbol: symbol, rewards: reward, offset: offset, limit: limit)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getBalance(
        userId: String? = nil,
        retried: Bool = false
    ) -> Single<ResponseAPIWalletGetBalances> {
        let methodAPIType = MethodAPIType.getBalance(userId: userId)
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIWalletGetBalances>)
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
                    BlockchainManager.instance.openCommunityBalance(communityCode: Config.defaultSymbol).subscribe().dispose()
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
        let methodAPIType = MethodAPIType.getBuyPrice(pointSymbol: symbol, quantity: quantity)
        return (executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired) as Single<ResponseAPIWalletGetPrice>)
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
        let methodAPIType = MethodAPIType.getSellPrice(quantity: quantity)
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIWalletGetPrice>)
            .map { result in
                var result = result
                result.quantity = quantity
                return result
            }
    }
    
    // MARK: - Rewards
    public func rewardsGetStateBulk(posts: [RequestAPIContentId]) -> Single<ResponseAPIRewardsGetStateBulk> {
        let methodAPIType = MethodAPIType.rewardsGetStateBulk(posts: posts)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false)
    }
    
    // MARK: - Donations
    public func getDonationsBulk(posts: [RequestAPIContentId]) -> Single<ResponseAPIWalletGetDonationsBulk> {
        let methodAPIType = MethodAPIType.getDonationsBulk(posts: posts)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false)
    }
}

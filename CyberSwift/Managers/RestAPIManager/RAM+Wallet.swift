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
                if result.balances.first(where: { $0.symbol == Config.defaultSymbol }) != nil {
                    BlockchainManager.instance.openCommunityBalance(communityCode: Config.defaultSymbol).subscribe().dispose()
                }
                return .just(result)
            }
    }
    
    public func getBuyPrice(
        symbol: String,
        quantity: String
    ) -> Single<ResponseAPIWalletGetPrice> {
        let methodAPIType = MethodAPIType.getBuyPrice(pointSymbol: symbol, quantity: quantity)
        return (executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPIWalletGetPrice>)
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
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Donations
    
}

//
//  ResponseAPI+Wallet.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIWalletGetBalances: Decodable {
    public let userId: String
    public let balances: [ResponseAPIWalletGetBalance]
}

public struct ResponseAPIWalletGetBalance: ListItemType {
    public let symbol: String
    public let balance: Double
    public let logo: String?
    public let name: String
    public let frozen: String?
    public let price: Double
    
    public var identity: String {
        return symbol
    }
    
    public func newUpdatedItem(from item: ResponseAPIWalletGetBalance) -> ResponseAPIWalletGetBalance? {
        ResponseAPIWalletGetBalance(symbol: item.symbol, balance: item.balance, logo: item.logo ?? self.logo, name: item.name, frozen: item.frozen ?? self.frozen, price: item.price)
    }
}

public struct ResponseAPIWalletGetTransferHistory: ListItemType {
    public let id: String
    public let sender: ResponseAPIWalletGetTransferHistorySender
    public let receiver: ResponseAPIWalletGetTransferHistoryReceiver
    public let quantity: Double
    public let symbol: String
    public let point: ResponseAPIWalletGetTransferHistoryPoint
    public let trxId: String
    public let memo: String
    public let timestamp: String
    public let meta: ResponseAPIWalletGetTransferHistoryMeta
    
    public var identity: String {
        return id
    }
    
    public func newUpdatedItem(from item: ResponseAPIWalletGetTransferHistory) -> ResponseAPIWalletGetTransferHistory? {
        ResponseAPIWalletGetTransferHistory(id: item.id, sender: item.sender, receiver: item.receiver, quantity: item.quantity, symbol: item.symbol, point: item.point, trxId: item.trxId, memo: item.memo, timestamp: item.timestamp, meta: item.meta)
    }
}

public struct ResponseAPIWalletGetTransferHistorySender: Codable, Equatable {
    public let userId: String
    public let username: String?
    public let avatarUrl: String?
}

public struct ResponseAPIWalletGetTransferHistoryReceiver: Codable, Equatable {
    public let userId: String
}

public struct ResponseAPIWalletGetTransferHistoryPoint: Codable, Equatable {
    public let name: String
    public let logo: String
    public let symbol: String
}

public struct ResponseAPIWalletGetTransferHistoryMeta: Codable, Equatable {
    public let actionType: String
    public let transferType: String
    public let exchangeAmount: Double
    public let direction: String
}

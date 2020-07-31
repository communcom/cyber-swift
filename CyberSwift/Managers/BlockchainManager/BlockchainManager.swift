//
//  BlockchainManager.swift
//  CyberSwift
//
//  Created by Artem Shilin on 23.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

public typealias SendPostCompletion = (transactionId: String?, userId: String?, permlink: String?)

public class BlockchainManager {
    // MARK: - Properties
    public static let instance = BlockchainManager()
    private let communCurrencyName = Config.defaultSymbol

    // MARK: - Updateauth Contracts
    public func changePassword(_ password: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let keys = RestAPIManager.instance.generateKeys(userId: userID, masterKey: password)
        guard let activeKey = try? EOSPublicKey(base58: keys["active"]!.publicKey!),
            let ownerKey = try? EOSPublicKey(base58: keys["owner"]!.publicKey!) else {
            return .error(CMError.unknown)
        }

        let activeWriter = PublicKeyWriterValue(publicKey: activeKey, isCurveParamK1: true)
        let ownerWriter = PublicKeyWriterValue(publicKey: ownerKey, isCurveParamK1: true)

        let active = EOSArgument.Password(account: NameWriterValue(name: userID),
                                          permission: NameWriterValue(name: "owner"),
                                          parent: NameWriterValue(name: "owner"),
                                          auth: EOSArgument.Password.Auth(threshold: 1,
                                                                          keys: [EOSArgument.Password.Keys(key: activeWriter, weight: 1)],
                                                                          accounts: [], waits: []))

        let owner = EOSArgument.Password(account: NameWriterValue(name: userID),
                                          permission: NameWriterValue(name: "owner"),
                                          parent: NameWriterValue(name: ""),
                                          auth: EOSArgument.Password.Auth(threshold: 1,
                                                                          keys: [EOSArgument.Password.Keys(key: ownerWriter, weight: 1)],
                                                                          accounts: [],
                                                                          waits: []))

        let args =  [active, owner]
        return EOSManager.pushAuthorized(account: .cyber, name: "updateauth", arguments: args, disableClientAuth: true, disableCyberBandwidth: true)
    }

    // MARK: - Communities Contracts
    public func voteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.VoteLeader(communCode: communityId, voter: userID, leader: leader)
        return EOSManager.voteLeader(args: args)
    }

    public func unvoteLeader(communityId: String, leader: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }
        let args = EOSArgument.UnvoteLeader(communCode: communityId, voter: userID, leader: leader)
        return EOSManager.unvoteLeader(args: args)
    }

    public func openCommunityBalance(communityCode: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let code = communityCode == communCurrencyName ? "4,\(communityCode)" : "3,\(communityCode)"

        let args = EOSArgument.OpenCommunBalance(owner: userID,
                                                 communCode: code,
                                                 ramPayer: userID)

        return EOSManager.openTokenBalance(args)
    }

    // MARK: - Wallet Contracts
    public func transferPoints(to: String,
                               number: Double,
                               currency: String,
                               memo: String = "") -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: to, quantityValue: quantityFormatter(number: number, currency: currency), memoValue: memo)

        if currency == communCurrencyName {
            return EOSManager.transferCommunToken(args)
        } else {
            return EOSManager.transferToken(args)
        }
    }

    public func buyPoints(communNumber: Double,
                          pointsCurrencyName: String) -> Single<String>  {

        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: BCAccountName.point.stringValue, quantityValue: quantityFormatter(number: communNumber, currency: communCurrencyName), memoValue: pointsCurrencyName)
        return EOSManager.buyToken(args)
    }

    public func sellPoints(number: Double, pointsCurrencyName: String) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: BCAccountName.point.stringValue, quantityValue: quantityFormatter(number: number, currency: pointsCurrencyName), memoValue: "")
        return EOSManager.sellToken(args)
    }
    
}

// MARK: - Helpers
extension BlockchainManager {
    private func quantityFormatter(number: Double, currency: String) -> String {
        let format = currency == communCurrencyName ? "%.4f" : "%.3f"
        return "\(String(format: format, number)) \(currency)"
    }

    public enum ReportReason: String, CaseIterable {
        case spam = "Spam"
        case harassment = "Harassment"
        case niguty = "Nudity"
        case violence = "Violence"
        case falseNews = "False News"
        case terrorism = "Terrorism"
        case breaksCommunityRules = "Breaks Community rules"
        case hateSpeech = "Hate Speech"
        case unauthorizedSales = "Unauthorized Sales"
        case abuse = "Abuse"
        case other = "Other"
    }
}

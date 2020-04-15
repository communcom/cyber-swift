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

    // MARK: - Users Contracts
    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let pinArgs = EOSArgument.PinUser(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }

    public func block(_ userToBlock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToBlock)
        return follow(userToBlock, isUnfollow: true)
            .flatMap {_ in EOSManager.block(args: args)}
    }

    public func unblock(_ userToUnblock: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.BlockUser(blocker: userID, blocking: userToUnblock)
        return EOSManager.unblock(args: args)
    }

    // MARK: - Communities Contracts
    public func followCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let followArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.followCommunity(followArgs)
    }

    public func unfollowCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let unFollowArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unfollowCommunity(unFollowArgs)
    }

    public func hideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return unfollowCommunity(communityId)
            .flatMap {_ in EOSManager.hideCommunity(args)}
    }

    public func unhideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unhideCommunity(args)
    }

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
                               currency: String) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.Transfer(fromValue: userID, toValue: to, quantityValue: quantityFormatter(number: number, currency: currency), memoValue: "")

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
        case hateSpeech = "Hate Speech"
        case unauthorizedSales = "Unauthorized Sales"
        case abuse = "Attempt to abuse"
        case other = "Other"
    }
}

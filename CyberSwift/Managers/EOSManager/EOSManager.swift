//
//  Tester.swift
//  CyberSwift
//
//  Created by msm72 on 1/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import eosswift
import Foundation
import RxSwift

enum BCAccountName: String {
    case point
    case ctrl
    case emit
    case list
    case gallery
    case social
    case token

    var stringValue: String {
        let prefix = self == .token ? "cyber" : "c"
        return prefix + "." + rawValue
    }
}

class EOSManager {
    // MARK: - Properties
    static let chainApi = ChainApiFactory.create(rootUrl: Config.blockchain_API_URL)
    static let historyApi = HistoryApiFactory.create(rootUrl: Config.blockchain_API_URL)

    // MARK: - Helpers
    static func signWebSocketSecretKey(userActiveKey: String) -> String? {
        do {
            guard let data = Config.webSocketSecretKey?.data(using: .utf8) else {
                throw ErrorAPI.blockchain(message: "secret key not found")
            }
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)

            let signature = PrivateKeySigning().sign(digest: data,
                    eosPrivateKey: privateKey)

            return signature
        } catch {
            return nil
        }
    }

    // MARK: - c.gallery
    static func vote(voteType: VoteActionType,
                     communityId: String,
                     author: String,
                     permlink: String) -> Completable {
        guard let userID = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let voteArgs = EOSArgument.VoteContent(communityID: communityId,
                voterValue: userID,
                authorValue: author,
                permlinkValue: permlink)

        return pushAuthorized(account: .gallery, name: voteType.rawValue, args: voteArgs)
                .flatMapToCompletable()
    }

    static func create(messageCreateArgs: EOSArgument.CreateContent) -> Single<String> {
        pushAuthorized(account: .gallery, name: "create", args: messageCreateArgs)
    }

    static func delete(messageArgs: EOSArgument.DeleteContent) -> Completable {
        pushAuthorized(account: .gallery, name: "remove", args: messageArgs)
                .flatMapToCompletable()
    }

    static func update(messageArgs: EOSArgument.UpdateContent) -> Single<String> {
        pushAuthorized(account: .gallery, name: "update", args: messageArgs)
    }

    static func report(args: EOSArgument.ReportContent) -> Single<String> {
        pushAuthorized(account: .gallery, name: "report", args: args)
    }

    // MARK: - c.social
    static func updateUserProfile(pinArgs: EOSArgument.PinUser, isUnpin: Bool) -> Single<String> {
        pushAuthorized(account: .social, name: isUnpin ? "unpin" : "pin", args: pinArgs)
    }

    static func updateUserProfile(blockArgs: EOSArgument.BlockUser, isUnblock: Bool) -> Single<String> {
        pushAuthorized(account: .social, name: isUnblock ? "unblock" : "block", args: blockArgs)
    }

    static func update(userProfileMetaArgs: EOSArgument.UpdateUser) -> Single<String> {
        pushAuthorized(account: .social, name: "updatemeta", args: userProfileMetaArgs)
    }

    static func delete(userProfileMetaArgs: EOSArgument.DeleteUser) -> Single<String> {
        pushAuthorized(account: .social, name: "deletemeta", args: userProfileMetaArgs)
    }

    static func block(args: EOSArgument.BlockUser) -> Single<String> {
        pushAuthorized(account: .social, name: "block", args: args)
    }

    static func unblock(args: EOSArgument.BlockUser) -> Single<String> {
        pushAuthorized(account: .social, name: "unblock", args: args)
    }

    // MARK: - c.ctrl
    static func voteLeader(args: EOSArgument.VoteLeader) -> Single<String> {
        pushAuthorized(account: .ctrl,
                name: "voteleader",
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }

    static func unvoteLeader(args: EOSArgument.UnvoteLeader) -> Single<String> {
        pushAuthorized(account: .ctrl,
                name: "unvotelead", 
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }

    // MARK: - c.list
    static func followCommunity(_ followArgs: EOSArgument.FollowUser) -> Single<String> {
        pushAuthorized(account: .list, name: "follow", args: followArgs)
    }

    static func unfollowCommunity(_ unfollowArgs: EOSArgument.FollowUser) -> Single<String> {
        pushAuthorized(account: .list, name: "unfollow", args: unfollowArgs)
    }

    static func hideCommunity(_ args: EOSArgument.FollowUser) -> Single<String> {
        pushAuthorized(account: .list, name: "hide", args: args)
    }

    static func unhideCommunity(_ args: EOSArgument.FollowUser) -> Single<String> {
        pushAuthorized(account: .list, name: "unhide", args: args)
    }

    // MARK: - cyber.token
    static func transferToken(args: EOSArgument.Transfer) -> Single<String> {
        pushAuthorized(account: .token, name: "transfer", args: args)
    }
}

// TODO
extension EOSManager {

//    static func transfer(account: TransactionAccountType,
//                         actionName: String,
//                         arguments: Encodable) -> Single<String> {
//        if !Config.isNetworkAvailable {
//            return .error(ErrorAPI.disableInternetConnection(message: nil))
//        }
//
//        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
//            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
//        }
//    }

    static func pushAuthorized(account: BCAccountName,
                               name: String,
                               args: Encodable,
                               disableClientAuth: Bool = false,
                               disableCyberBandwidth: Bool = false) -> Single<String> {

        let expiration = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds)

        Logger.log(message: args.convertToJSON(), event: .request)

        // Offline mode
        if !Config.isNetworkAvailable {
            return .error(ErrorAPI.disableInternetConnection(message: nil))
        }

        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        // Action 1
        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: userID),
                permission: AccountNameWriterValue(name: "active"))

        let transactionAuthorizationAbiClient = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: account.stringValue),
                permission: AccountNameWriterValue(name: "clients"))

        var auth = [transactionAuthorizationAbiActive, transactionAuthorizationAbiClient]
        if disableClientAuth {
            auth.removeLast()
        }

        let action1 = ActionAbi(
                account: AccountNameWriterValue(name: account.stringValue),
                name: AccountNameWriterValue(name: name),
                authorization: auth,
                data: DataWriterValue(hex: args.toHex()))
        // Action 2
        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: "providebw"))

        let args2 = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: userID))

        let action2 = ActionAbi(account: AccountNameWriterValue(name: "cyber"),
                name: AccountNameWriterValue(name: "providebw"),
                authorization: [transactionAuthorizationAbiBandwidth],
                data: DataWriterValue(hex: args2.toHex()))

        // Action 3
        let args3 = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: account.stringValue))


        let action3 = ActionAbi(
                account: AccountNameWriterValue(name: "cyber"),
                name: AccountNameWriterValue(name: "providebw"),
                authorization: [transactionAuthorizationAbiBandwidth],
                data: DataWriterValue(hex: args3.toHex()))

        let transaction = EOSTransaction(chainApi: EOSManager.chainApi)

        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            var actions = [action1, action2, action3]
            if disableCyberBandwidth {
                actions.removeLast()
            }
            let request = transaction.push(expirationDate: expiration, actions: actions, authorizingPrivateKey: privateKey)

            return request.catchError { (error) -> Single<String> in
                if let error = error as? ErrorAPI {
                    switch error {
                    case .balanceNotExist:
                        return openBalance(args: args).flatMap { (_) -> Single<String> in
                            return pushAuthorized(account: account, name: name, args: args, disableClientAuth: disableClientAuth, disableCyberBandwidth: disableCyberBandwidth)
                        }
                    default:
                        break
                    }
                }
                return .error(error)
            }
        } catch {
            return .error(error)
        }
    }

    private static func openBalance(args: Encodable) -> Single<String> {
        guard let communCodeArgs = args as? EOSArgumentCodeProtocol else {
            return .error(ErrorAPI.requestFailed(message: "balance does not exist"))
        }

        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let code = communCodeArgs.getCode()

        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: userID),
                permission: AccountNameWriterValue(name: "active"))

        let balanceArgs = EOSArgument.OpenBalance(owner: AccountNameWriterValue(name: userID),
                communCode: code,
                ramPayer: AccountNameWriterValue(name: userID))

        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: "providebw"))

        let action1 = ActionAbi(account: AccountNameWriterValue(name: "c.point"),
                name: AccountNameWriterValue(name: "open"),
                authorization: [transactionAuthorizationAbiActive],
                data: DataWriterValue(hex: balanceArgs.toHex()))

        let args2 = EOSArgument.CommunBandwidthProvider(
                provider: AccountNameWriterValue(name: "c"),
                account: AccountNameWriterValue(name: userID))

        let action2 = ActionAbi(account: AccountNameWriterValue(name: "cyber"),
                name: AccountNameWriterValue(name: "providebw"),
                authorization: [transactionAuthorizationAbiBandwidth],
                data: DataWriterValue(hex: args2.toHex()))

        let transaction = EOSTransaction(chainApi: EOSManager.chainApi)
        print("action1 hex: \(action1.toHex())")
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            return transaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [action1, action2], authorizingPrivateKey: privateKey)
        } catch {
            return .error(error)
        }
    }
}

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
import Crashlytics

enum BCAccountName: String {
    case point
    case ctrl
    case emit
    case list
    case gallery
    case social
    case token
    case cyber

    var stringValue: String {
        if self == .cyber {
            return "cyber"
        }

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
                throw CMError.blockchainError(message: ErrorMessage.secretKeyNotFound.rawValue, code: 0)
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
                     permlink: String) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }

        let voteArgs = EOSArgument.VoteContent(communityID: communityId,
                voterValue: userID,
                authorValue: author,
                permlinkValue: permlink)

        return pushAuthorized(account: .gallery, name: voteType.rawValue, args: voteArgs)
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

    static func regLeader(args: EOSArgument.RegLeader) -> Single<String> {
        pushAuthorized(account: .ctrl,
                name: "regleader",
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }

    static func approveProposal(args: EOSArgument.ProposalApprove) -> Single<String> {
        pushAuthorized(account: .ctrl,
                    name: "approve",
                    args: args,
                    disableClientAuth: true,
                    disableCyberBandwidth: true)
    }

    static func unapproveProposal(args: EOSArgument.ProposalApprove) -> Single<String> {
        pushAuthorized(account: .ctrl,
                name: "unapprove",
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }

    static func banContnent(args: EOSArgument.Propose) -> Single<String> {
           pushAuthorized(account: .ctrl,
                   name: "propose",
                   args: args,
                   disableClientAuth: true,
                   disableCyberBandwidth: true)
    }

    static func execProposal(args: EOSArgument.ProposalApprove) -> Single<String> {
        pushAuthorized(account: .ctrl,
                name: "exec",
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
    static func transferCommunToken(_ args: EOSArgument.Transfer) -> Single<String> {
        pushAuthorized(account: .token, name: "transfer", args: args, disableClientAuth: true, disableCyberBandwidth: true)
    }

    static func buyToken(_ args: EOSArgument.Transfer) -> Single<String> {
        pushAuthorized(account: .token, name: "transfer", args: args, disableClientAuth: true, disableCyberBandwidth: true)
    }

    static func openTokenBalance(_ args: EOSArgument.OpenCommunBalance) -> Single<String> {
        pushAuthorized(account: .token, name: "open", args: args, disableClientAuth: true, disableCyberBandwidth: true, disableProvidebw: false)
    }

    // MARK: - c.point
    static func transferToken(_ args: EOSArgument.Transfer) -> Single<String> {
        pushAuthorized(account: .point, name: "transfer", args: args, disableClientAuth: true, disableCyberBandwidth: false)
    }

    static func sellToken(_ args: EOSArgument.Transfer) -> Single<String> {
        pushAuthorized(account: .point, name: "transfer", args: args, disableClientAuth: true, disableCyberBandwidth: false)
    }
}

extension EOSManager {
    static func pushAuthorized(account: BCAccountName,
                               name: String,
                               args: Encodable,
                               disableClientAuth: Bool = false,
                               disableCyberBandwidth: Bool = false,
                               disableProvidebw: Bool = false) -> Single<String> {
        return pushAuthorized(account: account, name: name, arguments: [args], disableClientAuth: disableClientAuth, disableCyberBandwidth: disableCyberBandwidth, disableProvidebw: disableProvidebw)
    }

    static func pushAuthorized(account: BCAccountName,
                               name: String,
                               arguments: [Encodable],
                               disableClientAuth: Bool = false,
                               disableCyberBandwidth: Bool = false,
                               disableProvidebw: Bool = false,
                               authPermissionIsOwner: Bool = false) -> Single<String> {

        // Offline mode
        if !Config.isNetworkAvailable {
            ErrorLogger.shared.recordError(CMError.noConnection, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
            return .error(CMError.noConnection)
        }

        guard let userID = Config.currentUser?.id else {
            ErrorLogger.shared.recordError(CMError.unauthorized())
            return .error(CMError.unauthorized())
        }

        // Action 1
        let namePermission = authPermissionIsOwner ? "owner" : "active"
        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: userID),
                permission: AccountNameWriterValue(name: namePermission))

        let transactionAuthorizationAbiClient = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: account.stringValue),
                permission: AccountNameWriterValue(name: "clients"))

        var auth = [transactionAuthorizationAbiActive, transactionAuthorizationAbiClient]
        if disableClientAuth {
            auth.removeLast()
        }

        var actions: [ActionAbi] = []
        for arg in arguments {
            Logger.log(message: arg.convertToJSON(), event: .request)
            let action = ActionAbi(account: AccountNameWriterValue(name: account.stringValue),
                                    name: AccountNameWriterValue(name: name),
                                    authorization: auth,
                                    data: DataWriterValue(hex: arg.toHex()))
            actions.append(action)
        }

        // Action 2
        let action2 = providebwAction(userID: userID)
        if !disableProvidebw {
            actions.append(action2)
        }

        // Action 3
        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: "providebw"))

        let args3 = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: account.stringValue))

        let action3 = ActionAbi(
                account: AccountNameWriterValue(name: "cyber"),
                name: AccountNameWriterValue(name: "providebw"),
                authorization: [transactionAuthorizationAbiBandwidth],
                data: DataWriterValue(hex: args3.toHex()))
        if !disableCyberBandwidth {
            actions.append(action3)
        }

        do {
            return push(actions: actions, authPermissionIsOwner: authPermissionIsOwner).catchError { (error) in
                if let error = error as? CMError {
                    switch error {
                    case .blockchainError(let message, _):
                        if message == ErrorMessage.balanceNotExist.rawValue || message ==  ErrorMessage.balanceNotOpened.rawValue {
                            return openBalance(args: arguments.first).flatMap { (_) -> Single<String> in
                                return push(actions: actions)
                            }
                        }
                    default:
                        break
                    }
                }
                return .error(error)
            }
        }
    }

    static func openBalance(args: Encodable?) -> Single<String> {
        var code: CyberSymbolWriterValue!

        if let args = args {
            guard let communCodeArgs = args as? EOSArgumentCodeProtocol else {
                return .error(CMError.invalidRequest(message: ErrorMessage.balanceNotExist.rawValue))
            }
            code = communCodeArgs.getCode()
        } else {
            return .error(CMError.invalidRequest(message: ErrorMessage.balanceNotExist.rawValue))
        }
        
        return openBalance(communityCode: code)
    }
    
    static func openBalance(communityCode: CyberSymbolWriterValue) -> Single<String> {
        guard let userID = Config.currentUser?.id else {
            return .error(CMError.unauthorized())
        }
        
        // action 1
        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: userID),
                permission: AccountNameWriterValue(name: "active"))
        
        let balanceArgs = EOSArgument.OpenBalance(owner: NameWriterValue(name: userID),
                communCode: communityCode,
                ramPayer: NameWriterValue(name: userID))

        let action1 = ActionAbi(account: AccountNameWriterValue(name: BCAccountName.point.stringValue),
                                name: AccountNameWriterValue(name: "open"),
                                authorization: [transactionAuthorizationAbiActive],
                                data: DataWriterValue(hex: balanceArgs.toHex()))

        // action 2
        let action2 = providebwAction(userID: userID)

        return push(actions: [action1, action2])
    }

    static func push(actions: [ActionAbi], authPermissionIsOwner: Bool = false) -> Single<String> {
        // check internet connection
        if !Config.isNetworkAvailable {
            ErrorLogger.shared.recordError(CMError.noConnection, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
            return .error(CMError.noConnection)
        }

        // check key
        let key = authPermissionIsOwner ? Config.currentUser?.ownerKeys?.privateKey : Config.currentUser?.activeKeys?.privateKey
        guard let userActiveKey = key else {
            ErrorLogger.shared.recordError(CMError.unauthorized())
            return .error(CMError.unauthorized())
        }

        do {
            let transaction = EOSTransaction(chainApi: EOSManager.chainApi)
            let expiration = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds)
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)

            return transaction.push(expirationDate: expiration, actions: actions, authorizingPrivateKey: privateKey)
        } catch {
            return .error(error)
        }
    }

    static func providebwAction(userID: String) -> ActionAbi {
        let args = EOSArgument.CommunBandwidthProvider(
                provider: AccountNameWriterValue(name: "c"),
                account: AccountNameWriterValue(name: userID))

        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: "c"),
                permission: AccountNameWriterValue(name: "providebw"))

        let action = ActionAbi(account: AccountNameWriterValue(name: "cyber"),
                name: AccountNameWriterValue(name: "providebw"),
                authorization: [transactionAuthorizationAbiBandwidth],
                data: DataWriterValue(hex: args.toHex()))

        return action
    }

    static func banUser(args: EOSArgument.BanUser) -> Single<String> {
        pushAuthorized(account: .list,
                name: "ban",
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }

    static func unbanUser(args: EOSArgument.BanUser) -> Single<String> {
        pushAuthorized(account: .list,
                name: "unban",
                args: args,
                disableClientAuth: true,
                disableCyberBandwidth: true)
    }
}

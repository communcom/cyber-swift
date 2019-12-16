//
//  Tester.swift
//  CyberSwift
//
//  Created by msm72 on 1/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
//  https://github.com/GolosChain/golos.contracts
//  https://github.com/GolosChain/cyberway.contracts/blob/38a15c23ea8e0538df52b3e36aeb77d6f3e98fbf/cyber.token/abi/cyber.token.abi
//  https://docs.google.com/document/d/1caNVBva1EDB9c9fA7K8Wutn1xlAimp23YCfKm_inx9E/edit
//  https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi#L297-L326
//  https://developers.eos.io/eosio-nodeos/reference#get_info
//  https://github.com/GolosChain/golos.contracts/blob/master/golos.ctrl/abi/golos.ctrl.abi
//

import eosswift
import Foundation
import RxSwift

enum TransactionAccountType: String {
    static let prefix = "c"
    case point          = "point"
    case ctrl           = "ctrl"
    case emit           = "emit"
    case list           = "list"
    case gallery        = "gallery"
    case social         = "social"
    
    var stringValue: String {
        return TransactionAccountType.prefix + "." + rawValue
    }
}

public struct ProviderArgs: Encodable {
    public let provider: AccountNameWriterValue
    public let account: AccountNameWriterValue
}

class EOSManager {
    // MARK: - Properties
    static let chainApi     =   ChainApiFactory.create(rootUrl: Config.blockchain_API_URL)
    static let historyApi   =   HistoryApiFactory.create(rootUrl: Config.blockchain_API_URL)

    // MARK: - BC Info
    static var chainInfo: Single<Info> {
        return EOSManager.chainApi.getInfo()
            .map { response -> Info in
                guard let body = response.body else {throw ErrorAPI.blockchain(message: "Can not retrieve chain info")}
                return body
            }
            .log(method: "getChainInfo")
    }
    
    static var headBlock: Single<Block> {
        return chainInfo
            .flatMap {info in
                let blockId = info.head_block_id
                return EOSManager.chainApi.getBlock(body: BlockNumOrId(block_num_or_id: blockId))
                    .map {block in
                        guard let body = block.body else {throw ErrorAPI.blockchain(message: "Can not retrieve headBlock")}
                        return body
                }
            }
            .log(method: "getChainHeadBlock")
    }
    
    static func getAccount(nickName: String) -> Single<Account> {
        return EOSManager.chainApi.getAccount(body: AccountName(account_name: nickName))
            .map {account in
                guard let body = account.body else {throw ErrorAPI.blockchain(message: "Can not retrieve account")}
                return body
            }
            .log(method: "getChainAccount")
    }
    
    static func getTransaction(_ blockNumberHint: String) -> Single<HistoricTransaction> {
        return EOSManager.historyApi.getTransaction(body: GetTransaction(id: blockNumberHint))
            .map {transaction in
                guard let body = transaction.body else {throw ErrorAPI.blockchain(message: "Can not retrieve transaction")}
                return body
            }
            .log(method: "getHistoricTransaction")
    }
    
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
    
    static func pushAuthorized(account: TransactionAccountType,
                               name: String,
                               args: Encodable,
                               expiration: Date = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds),
                               disableClientAuth: Bool = false,
                               disableCyberBandwidth: Bool  = false) -> Single<String> {
        
        Logger.log(message: args.convertToJSON(), event: .request)

        // Offline mode
        if !Config.isNetworkAvailable { return .error(ErrorAPI.disableInternetConnection(message: nil)) }

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

        let args2 = EOSTransaction.CommunBandwidthProvider(
            provider: AccountNameWriterValue(name: "c"),
            account: AccountNameWriterValue(name: userID))

        let action2 = ActionAbi(account: AccountNameWriterValue(name: "cyber"),
                                name: AccountNameWriterValue(name: "providebw"),
                                authorization: [transactionAuthorizationAbiBandwidth],
                                data: DataWriterValue(hex: args2.toHex()))

        // Action 3
        let args3 = EOSTransaction.CommunBandwidthProvider(
            provider: AccountNameWriterValue(name: "c"),
            account: AccountNameWriterValue(name: account.stringValue))
        
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
                            return pushAuthorized(account: account, name: name, args: args, expiration: expiration, disableClientAuth: disableClientAuth, disableCyberBandwidth: disableCyberBandwidth)
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

    private static func openBalance(args: Encodable)  -> Single<String> {
        guard let communCodeArgs = args as? HasCommunCode else {
            return .error(ErrorAPI.requestFailed(message: "balance does not exist"))
        }

        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }

        let code = communCodeArgs.getCode()

        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
            actor: AccountNameWriterValue(name: userID),
            permission: AccountNameWriterValue(name: "active"))

        let balanceArgs = EOSTransaction.OpenBalanceArgs(owner: AccountNameWriterValue(name: userID),
                                                         commun_code: code,
                                                         ram_payer: AccountNameWriterValue(name: userID))

        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
            actor: AccountNameWriterValue(name: "c"),
            permission: AccountNameWriterValue(name: "providebw"))

        let action1 = ActionAbi(account: AccountNameWriterValue(name: "c.point"),
                                name: AccountNameWriterValue(name: "open"),
                                authorization: [transactionAuthorizationAbiActive],
                                data: DataWriterValue(hex: balanceArgs.toHex()))

        let args2 = EOSTransaction.CommunBandwidthProvider(
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
    
    // MARK: - Contract `gls.publish`
    
    static func createNewAccount(nickName: String) -> Single<String> {
        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        guard let currentUserPublicKey = try? EOSPublicKey(base58: userActiveKey) else {
            return .error(ErrorAPI.blockchain(message: "Can not create public key"))
        }
        
        let owner = AccountRequiredAuthAbi(
            threshold: 1,
            keys: [
                AccountKeyAbi(
                    key: PublicKeyWriterValue(
                        publicKey: currentUserPublicKey,
                        isCurveParamK1: true
                    ),
                    weight: 1)
            ],
            accounts: StringCollectionWriterValue(value: []),
            waits: StringCollectionWriterValue(value: []))
        
        let createNewAccountArgs = NewAccountArgs(
            creator: AccountNameWriterValue(name: userID),
            name: AccountNameWriterValue(name: userID),
            owner: owner,
            active: owner)
        
        return pushAuthorized(account: .gallery, name: "newaccount", args: createNewAccountArgs)
    }
    
    static func vote(voteType: VoteActionType,
                     communityId: String,
                     author: String,
                     permlink: String) -> Completable {
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare data

        var voteArgs: Encodable!

        if voteType == .unvote {
            voteArgs = EOSTransaction.UnvoteArgs.init(communityID: communityId,
                                                      voterValue: userID,
                                                      authorValue: author,
                                                      permlinkValue: permlink)
        } else {
            voteArgs = EOSTransaction.UpvoteArgs.init(communityID: communityId,
                                                      voterValue: userID,
                                                      authorValue: author,
                                                      permlinkValue: permlink)

        }

        return pushAuthorized(account: .gallery, name: voteType.rawValue, args: voteArgs)
            .flatMapToCompletable()
    }
    
    static func create(messageCreateArgs: EOSTransaction.MessageCreateArgs) -> Single<String> {
        // Prepare data
        Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
        // send transaction
        return pushAuthorized(account: .gallery, name: "create", args: messageCreateArgs)
    }
    
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
        return pushAuthorized(account: .gallery, name: "remove", args: messageArgs)
            .flatMapToCompletable()
    }
    
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs) -> Single<String> {
        return pushAuthorized(account: .gallery, name: "update", args: messageArgs)
    }
    
    static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs) -> Single<String> {
        return pushAuthorized(account: .gallery, name: "changereput", args: changereputArgs)
    }
    
    static func reblog(args: EOSTransaction.ReblogArgs) -> Single<String> {
        return pushAuthorized(account: .gallery, name: "reblog", args: args)
    }
    
    // MARK: - Contract `gls.vesting`
//    static func publish(transferArgs: EOSTransaction.TransferArgs) -> Single<String> {
//        // Prepare data
//        let transferArgsData = DataWriterValue(hex: transferArgs.toHex())
//
//        // Send transaction
//        return pushAuthorized(account: .glsVesting, name: "transfer", data: transferArgsData)
//    }
    
    // MARK: - Contract `gls.social`
    static func updateUserProfile(pinArgs: EOSTransaction.UserProfilePinArgs, isUnpin: Bool) -> Single<String> {
        return pushAuthorized(account: .social, name: isUnpin ? "unpin": "pin", args: pinArgs)
    }
    
    static func updateUserProfile(blockArgs: EOSTransaction.UserProfileBlockArgs, isUnblock: Bool) -> Single<String> {
        return pushAuthorized(account: .social, name: isUnblock ? "unblock": "block", args: blockArgs)
    }
    
    static func update(userProfileMetaArgs: EOSTransaction.UserProfileUpdatemetaArgs) -> Single<String> {
        Logger.log(message: "\nuserProfileMetaArgs: \n\(userProfileMetaArgs.convertToJSON())\n", event: .debug)
        return pushAuthorized(account: .social, name: "updatemeta", args: userProfileMetaArgs)
    }
    
    static func delete(userProfileMetaArgs: EOSTransaction.UserProfileDeleteArgs) -> Single<String> {
        return pushAuthorized(account: .social, name: "deletemeta", args: userProfileMetaArgs)
    }
    
    static func block(args: EOSTransaction.BlockUserArgs) -> Single<String> {
        return pushAuthorized(account: .social, name: "block", args: args)
    }
    
    static func unblock(args: EOSTransaction.BlockUserArgs) -> Single<String> {
        return pushAuthorized(account: .social, name: "unblock", args: args)
    }
    
    // MARK: - Contract `gls.ctrl`
    static func reg(witnessArgs: EOSTransaction.RegwitnessArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl, name: "regwitness", args: witnessArgs)
    }
    
    static func vote(witnessArgs: EOSTransaction.VotewitnessArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl, name: "votewitness", args: witnessArgs)
    }
    
    static func unvote(witnessArgs: EOSTransaction.UnvotewitnessArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl, name: "unvotewitn", args: witnessArgs)
    }
    
    static func unreg(witnessArgs: EOSTransaction.UnregwitnessArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl, name: "unregwitness", args: witnessArgs)
    }
    
    static func voteLeader(args: EOSTransaction.VoteLeaderArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl,
                              name: "voteleader",
                              args: args,
                              disableClientAuth: true,
                              disableCyberBandwidth: true)
    }
    
    static func unvoteLeader(args: EOSTransaction.UnvoteLeaderArgs) -> Single<String> {
        return pushAuthorized(account: .ctrl,
                              name: "unvotelead",
                              args: args,
                              disableClientAuth: true,
                              disableCyberBandwidth: true)
    }

    static func report(args: EOSTransaction.ReprotArgs) -> Single<String> {
        return pushAuthorized(account: .gallery, name: "report", args: args)
    }
}

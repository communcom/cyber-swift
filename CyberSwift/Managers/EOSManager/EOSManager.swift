//
//  Tester.swift
//  CyberSwift
//
//  Created by msm72 on 1/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
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
            
            let signature = PrivateKeySigning().sign(digest:            data,
                                                     eosPrivateKey:     privateKey)
            
            return signature
        } catch {
            return nil
        }
    }
    
    static func pushAuthorized(account: TransactionAccountType, name: String, data: DataWriterValue, expiration: Date = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds)) -> Single<String> {
        
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }

        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Action 1
        let transactionAuthorizationAbiActive = TransactionAuthorizationAbi(
            actor:        AccountNameWriterValue(name:    userID),
            permission:   AccountNameWriterValue(name:    "active"))

        let transactionAuthorizationAbiClient = TransactionAuthorizationAbi(
            actor:        AccountNameWriterValue(name:    account.stringValue),
            permission:   AccountNameWriterValue(name:    "clients"))
        
        let action1 = ActionAbi(
            account: AccountNameWriterValue(name: account.stringValue),
            name: AccountNameWriterValue(name: name),
            authorization: [transactionAuthorizationAbiActive, transactionAuthorizationAbiClient],
            data: data)
        print("action1 hex: \(action1.toHex())")
        // Action 2
        let transactionAuthorizationAbiBandwidth = TransactionAuthorizationAbi(
            actor:        AccountNameWriterValue(name:    "c"),
            permission:   AccountNameWriterValue(name:    "providebw"))
        let args2 = EOSTransaction.CommunBandwidthProvider(
            provider: AccountNameWriterValue(name:    "c"),
            account: AccountNameWriterValue(name:    userID))

        let action2 = ActionAbi(
            account: AccountNameWriterValue(name: "cyber"),
            name: AccountNameWriterValue(name: "providebw"),
            authorization: [transactionAuthorizationAbiBandwidth],
            data: DataWriterValue(hex: args2.toHex()))
        print("action2 hex: \(action2.toHex())")

        // Action 3
        let args3 = EOSTransaction.CommunBandwidthProvider(
            provider: AccountNameWriterValue(name:    "c"),
            account: AccountNameWriterValue(name:    account.stringValue))
        
        let action3 = ActionAbi(
            account: AccountNameWriterValue(name: "cyber"),
            name: AccountNameWriterValue(name: "providebw"),
            authorization: [transactionAuthorizationAbiBandwidth],
            data: DataWriterValue(hex: args3.toHex()))
        print("action3 hex: \(action3.toHex())")

        let transaction = EOSTransaction(chainApi: EOSManager.chainApi)

        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            return transaction.push(expirationDate: expiration, actions: [action1, action2, action3], authorizingPrivateKey: privateKey)
        } catch {
            return .error(error)
        }
    }
    
    //  MARK: - Contract `gls.publish`
    
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
                    weight:  1)
            ],
            accounts:    StringCollectionWriterValue(value: []),
            waits:       StringCollectionWriterValue(value: []))
        
        let createNewAccountArgs = NewAccountArgs(
            creator:      AccountNameWriterValue(name:    userID),
            name:         AccountNameWriterValue(name:    userID),
            owner:        owner,
            active:       owner)
        
        let createNewAccountArgsData = DataWriterValue(hex: createNewAccountArgs.toHex())
        
        return pushAuthorized(account: .gallery, name: "newaccount", data: createNewAccountArgsData)
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

        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())
        print(voteArgs.toHex())
        return pushAuthorized(account: .gallery, name: voteType.rawValue, data: voteArgsData)
            .flatMapToCompletable()
    }
    
    static func create(messageCreateArgs: EOSTransaction.MessageCreateArgs) -> Single<String> {
        // Prepare data
        Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
        let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
        
        // send transaction
        return pushAuthorized(account: .gallery, name: "create", data: messageCreateArgsData)
    }
    
    
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
        // Prepare data
        let messageDeleteArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        
        // Send transaction
        return pushAuthorized(account: .gallery, name: "remove", data: messageDeleteArgsData)
            .flatMapToCompletable()
    }
    
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs) -> Single<String> {
        // Prepare data
        let messageUpdateArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .gallery, name: "update", data: messageUpdateArgsData)
    }
    
    static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs) -> Single<String> {
        // Prepare data
        let changereputArgsData = DataWriterValue(hex: changereputArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .gallery, name: "changereput", data: changereputArgsData)
    }
    
    static func reblog(args: EOSTransaction.ReblogArgs) -> Single<String> {
        // Prepare data
        let reblogArgsData = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return pushAuthorized(account: .gallery, name: "reblog", data: reblogArgsData)
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
        // Prepare data
        let pinArgsData = DataWriterValue(hex: pinArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .social, name: isUnpin ? "unpin": "pin", data: pinArgsData)
    }
    
    static func updateUserProfile(blockArgs: EOSTransaction.UserProfileBlockArgs, isUnblock: Bool) -> Single<String> {
        // Prepare data
        let blockArgsData = DataWriterValue(hex: blockArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .social, name: isUnblock ? "unblock": "block", data: blockArgsData)
    }
    
    static func update(userProfileMetaArgs: EOSTransaction.UserProfileUpdatemetaArgs) -> Single<String> {
        Logger.log(message: "\nuserProfileMetaArgs: \n\(userProfileMetaArgs.convertToJSON())\n", event: .debug)
        
        // Prepare data
        let userProfileUpdatemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .social, name: "updatemeta", data: userProfileUpdatemetaArgsData)
    }
    
    static func delete(userProfileMetaArgs: EOSTransaction.UserProfileDeleteArgs) -> Single<String> {
        // Prepare data
        let userProfileDeletemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .social, name: "deletemeta", data: userProfileDeletemetaArgsData)
    }
    
    static func block(args: EOSTransaction.BlockUserArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        return pushAuthorized(account: .social, name: "block", data: data)
    }
    
    static func unblock(args: EOSTransaction.BlockUserArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        return pushAuthorized(account: .social, name: "unblock", data: data)
    }
    
    // MARK: - Contract `gls.ctrl`
    static func reg(witnessArgs: EOSTransaction.RegwitnessArgs) -> Single<String> {
        // Prepare data
        let regwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .ctrl, name: "regwitness", data: regwithessArgsData)
    }
    
    static func vote(witnessArgs: EOSTransaction.VotewitnessArgs) -> Single<String> {
        // Prepare data
        let votewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .ctrl, name: "votewitness", data: votewithessArgsData)
    }
    
    static func unvote(witnessArgs: EOSTransaction.UnvotewitnessArgs) -> Single<String> {
        // Prepare data
        let unvotewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .ctrl, name: "unvotewitn", data: unvotewithessArgsData)
    }
    
    static func unreg(witnessArgs: EOSTransaction.UnregwitnessArgs) -> Single<String> {
        // Prepare data
        let unregwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .ctrl, name: "unregwitness", data: unregwithessArgsData)
    }
    
    static func voteLeader(args: EOSTransaction.VoteLeaderArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        return pushAuthorized(account: .ctrl, name: "voteleader", data: data)
    }
    
    static func unvoteLeader(args: EOSTransaction.UnvoteLeaderArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        return pushAuthorized(account: .ctrl, name: "unvotelead", data: data)
    }
}

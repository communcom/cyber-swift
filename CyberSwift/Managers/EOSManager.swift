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
    case glsPublish = "gls.publish"
    case glsVesting = "gls.vesting"
    case glsSocial = "gls.social"
    case glsCtrl = "gls.ctrl"
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
            .map {$0 as! Info}
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
            .map {$0 as! Block}
    }
    
    static func getAccount(nickName: String) -> Single<Account> {
        return EOSManager.chainApi.getAccount(body: AccountName(account_name: nickName))
            .map {account in
                guard let body = account.body else {throw ErrorAPI.blockchain(message: "Can not retrieve account")}
                return body
            }
            .log(method: "getChainAccount")
            .map {$0 as! Account}
    }
    
    static func getTransaction(_ blockNumberHint: String) -> Single<HistoricTransaction> {
        return EOSManager.historyApi.getTransaction(body: GetTransaction(id: blockNumberHint))
            .map {transaction in
                guard let body = transaction.body else {throw ErrorAPI.blockchain(message: "Can not retrieve transaction")}
                return body
            }
            .log(method: "getHistoricTransaction")
            .map {$0 as! HistoricTransaction}
    }
    
    // MARK: - Helpers
    static func signWebSocketSecretKey(userActiveKey: String) -> String? {
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            let signature = PrivateKeySigning().sign(digest:            Config.webSocketSecretKey.data(using: .utf8)!,
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
        
        // Prepare actions
        let transactionAuthorizationAbi = TransactionAuthorizationAbi(
            actor:        AccountNameWriterValue(name:    userID),
            permission:   AccountNameWriterValue(name:    "active"))
        
        let action = ActionAbi(
            account: AccountNameWriterValue(name: account.rawValue),
            name: AccountNameWriterValue(name: name),
            authorization: [transactionAuthorizationAbi],
            data: data)
        
        let secondTransactionAuthorizationAbi = TransactionAuthorizationAbi(
            actor: AccountNameWriterValue(name: "gls"),
            permission: AccountNameWriterValue(name: "providebw"))
        let providerArgs = ProviderArgs(
            provider: AccountNameWriterValue(name: "gls"),
            account: AccountNameWriterValue(name: userID))
        let action2 = ActionAbi(account: AccountNameWriterValue(name: "cyber"), name: AccountNameWriterValue(name: "providebw"), authorization: [secondTransactionAuthorizationAbi], data: DataWriterValue(hex: providerArgs.toHex()))
        
        let transaction = EOSTransaction(chainApi: EOSManager.chainApi)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            return transaction.push(expirationDate: expiration, actions: [action, action2], authorizingPrivateKey: privateKey)
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
        
        return pushAuthorized(account: .glsPublish, name: "newaccount", data: createNewAccountArgsData)
    }
    
    static func vote(voteType:  VoteActionType,
                     author:    String,
                     permlink:  String,
                     weight:    Int16) -> Completable {
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare data
        let voteArgs: Encodable = (voteType == .unvote) ?   EOSTransaction.UnvoteArgs.init(voterValue:          userID,
                                                                                           authorValue:         author,
                                                                                           permlinkValue:       permlink) :
            EOSTransaction.UpvoteArgs.init(voterValue:          userID,
                                           authorValue:         author,
                                           permlinkValue:       permlink,
                                           weightValue:         weight)
        
        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())
        
        return pushAuthorized(account: .glsPublish, name: voteType.rawValue, data: voteArgsData)
            .flatMapToCompletable()
    }
    
    static func create(messageCreateArgs: EOSTransaction.MessageCreateArgs) -> Single<String> {
        // Prepare data
        Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
        let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
        
        // send transaction
        return pushAuthorized(account: .glsPublish, name: "createmssg", data: messageCreateArgsData)
    }
    
    
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
        // Prepare data
        let messageDeleteArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "deletemssg", data: messageDeleteArgsData)
            .flatMapToCompletable()
    }
    
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs) -> Single<String> {
        // Prepare data
        let messageUpdateArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "updatemssg", data: messageUpdateArgsData)
    }
    
    static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs) -> Single<String> {
        // Prepare data
        let changereputArgsData = DataWriterValue(hex: changereputArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "changereput", data: changereputArgsData)
    }
    
    static func reblog(args: EOSTransaction.ReblogArgs) -> Single<String> {
        // Prepare data
        let reblogArgsData = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "reblog", data: reblogArgsData)
    }
    
    // MARK: - Contract `gls.vesting`
    static func publish(transferArgs: EOSTransaction.TransferArgs) -> Single<String> {
        // Prepare data
        let transferArgsData = DataWriterValue(hex: transferArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsVesting, name: "transfer", data: transferArgsData)
    }
    
    // MARK: - Contract `gls.social`
    static func updateUserProfile(pinArgs: EOSTransaction.UserProfilePinArgs, isUnpin: Bool) -> Single<String> {
        // Prepare data
        let pinArgsData = DataWriterValue(hex: pinArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: isUnpin ? "unpin": "pin", data: pinArgsData)
    }
    
    static func updateUserProfile(blockArgs: EOSTransaction.UserProfileBlockArgs, isUnblock: Bool) -> Single<String> {
        // Prepare data
        let blockArgsData = DataWriterValue(hex: blockArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: isUnblock ? "unblock": "block", data: blockArgsData)
    }
    
    static func update(userProfileMetaArgs: EOSTransaction.UserProfileUpdatemetaArgs) -> Single<String> {
        Logger.log(message: "\nuserProfileMetaArgs: \n\(userProfileMetaArgs.convertToJSON())\n", event: .debug)
        
        // Prepare data
        let userProfileUpdatemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: "updatemeta", data: userProfileUpdatemetaArgsData)
    }
    
    static func delete(userProfileMetaArgs: EOSTransaction.UserProfileDeleteArgs) -> Single<String> {
        // Prepare data
        let userProfileDeletemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: "deletemeta", data: userProfileDeletemetaArgsData)
    }
    
    // MARK: - Contract `gls.ctrl`
    static func reg(witnessArgs: EOSTransaction.RegwitnessArgs) -> Single<String> {
        // Prepare data
        let regwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "regwitness", data: regwithessArgsData)
    }
    
    static func vote(witnessArgs: EOSTransaction.VotewitnessArgs) -> Single<String> {
        // Prepare data
        let votewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "votewitness", data: votewithessArgsData)
    }
    
    static func unvote(witnessArgs: EOSTransaction.UnvotewitnessArgs) -> Single<String> {
        // Prepare data
        let unvotewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "unvotewitn", data: unvotewithessArgsData)
    }
    
    static func unreg(witnessArgs: EOSTransaction.UnregwitnessArgs) -> Single<String> {
        // Prepare data
        let unregwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "unregwitness", data: unregwithessArgsData)
    }
}

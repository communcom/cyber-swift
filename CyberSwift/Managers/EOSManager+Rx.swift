//
//  EOSManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension EOSManager: ReactiveCompatible {}

extension Reactive where Base: EOSManager {
    // Get chain info
    static var chainInfo: Single<Info> {
        return EOSManager.chainApi.getInfo()
            .flatMap({ (response) -> Single<Info> in
                guard let body = response.body else {throw ErrorAPI.blockchain(message: "Can not retrieve chain info")}
                return .just(body)
            })
    }
    
    //  MARK: - Contract `gls.publish`
    private static func glsPublishPushTransaction(actionName: String, data: DataWriterValue, expiration: Date = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds)) -> Single<ChainResponse<TransactionCommitted>> {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare action
        let transactionAuthorizationAbi = TransactionAuthorizationAbi(
                actor:        AccountNameWriterValue(name:    userNickName),
                permission:   AccountNameWriterValue(name:    "active"))
        
        let action = ActionAbi(
                account: AccountNameWriterValue(name: "gls.publish"),
                name: AccountNameWriterValue(name: actionName),
                authorization: [transactionAuthorizationAbi],
                data: data)
        
        let transaction = EOSTransaction(chainApi: EOSManager.chainApi)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            return transaction.push(expirationDate: expiration, actions: [action], authorizingPrivateKey: privateKey)
                .mapCachedError()
        } catch {
            return .error(error)
        }
    }
    
//    static func createNewAccount(nickName: String) -> Single<ChainResponse<TransactionCommitted>> {
//
//    }
    
    static func vote(voteType: VoteType, author: String, permlink: String, weight: Int16, refBlockNum: UInt64) -> Completable {
        guard let userNickName = Config.currentUser.nickName, let _ = Config.currentUser.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare data
        let voteArgs: Encodable = (voteType == .unvote) ?
            EOSTransaction.UnvoteArgs.init(voterValue: userNickName,
                                           authorValue:         author,
                                           permlinkValue:       permlink)
            :
            EOSTransaction.UpvoteArgs.init(voterValue:          userNickName,
                                           authorValue:         author,
                                           permlinkValue:       permlink,
                                           weightValue:         weight)
        
        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())

        
        return glsPublishPushTransaction(actionName: voteType.rawValue, data: voteArgsData)
            .flatMap {response -> Single<ChainResponse<TransactionCommitted>> in
                if voteType == .unvote {
                    return .just(response)
                }
                
                // Update user profile reputation
                let changereputArgs = EOSTransaction.UserProfileChangereputArgs(voterValue: userNickName, authorValue: author, rsharesValue: voteType == .upvote ? 1 : -1)
                return EOSManager.rx.updateUserProfile(changereputArgs: changereputArgs)
            }
            .flatMapToCompletable()
    }
    
    static func create(messageCreateArgs: EOSTransaction.MessageCreateArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare arguments
        Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
        let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
        
        // send transaction
        return glsPublishPushTransaction(actionName: "createmssg", data: messageCreateArgsData)
    }
    
    
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
        // Prepare arguments
        let messageDeleteArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        
        // Send transaction
        return glsPublishPushTransaction(actionName: "deletemssg", data: messageDeleteArgsData)
            .flatMapToCompletable()
    }
    
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare arguments
        let messageUpdateArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        // Send transaction
        return glsPublishPushTransaction(actionName: "updatemssg", data: messageUpdateArgsData)
    }
    
    static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare arguments
        let changereputArgsData = DataWriterValue(hex: changereputArgs.toHex())
        
        // Send transaction
        return glsPublishPushTransaction(actionName: "changereput", data: changereputArgsData)
    }
    
    static func reblog(args: EOSTransaction.ReblogArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare arguments
        let reblogArgsData = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return glsPublishPushTransaction(actionName: "reblog", data: reblogArgsData)
    }
}

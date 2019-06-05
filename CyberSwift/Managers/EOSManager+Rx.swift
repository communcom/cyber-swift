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

enum TransactionAccountType: String {
    case glsPublish = "gls.publish"
    case glsVesting = "gls.vesting"
    case glsSocial = "gls.social"
    case glsCtrl = "gls.ctrl"
}

extension Reactive where Base: EOSManager {
    // MARK: - Helpers
    static var chainInfo: Single<Info> {
        return EOSManager.chainApi.getInfo()
            .flatMap({ (response) -> Single<Info> in
                guard let body = response.body else {throw ErrorAPI.blockchain(message: "Can not retrieve chain info")}
                return .just(body)
            })
    }
    
    static func pushAuthorized(account: TransactionAccountType, name: String, data: DataWriterValue, expiration: Date = Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds)) -> Single<ChainResponse<TransactionCommitted>> {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare action
        let transactionAuthorizationAbi = TransactionAuthorizationAbi(
            actor:        AccountNameWriterValue(name:    userNickName),
            permission:   AccountNameWriterValue(name:    "active"))
        
        let action = ActionAbi(
            account: AccountNameWriterValue(name: account.rawValue),
            name: AccountNameWriterValue(name: name),
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
    
    //  MARK: - Contract `gls.publish`
    
//    static func createNewAccount(nickName: String) -> Single<ChainResponse<TransactionCommitted>> {
//
//    }
    
    static func vote(voteType: VoteActionType, author: String, permlink: String, weight: Int16) -> Completable {
        guard let userNickName = Config.currentUser.nickName, let _ = Config.currentUser.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        // Prepare data
        let voteArgs: Encodable = (voteType == .unvote) ?
            EOSTransaction.UnvoteArgs.init(voterValue:          userNickName,
                                           authorValue:         author,
                                           permlinkValue:       permlink)
            :
            EOSTransaction.UpvoteArgs.init(voterValue:          userNickName,
                                           authorValue:         author,
                                           permlinkValue:       permlink,
                                           weightValue:         weight)
        
        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())

        return pushAuthorized(account: .glsPublish, name: voteType.rawValue, data: voteArgsData)
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
    
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let messageUpdateArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "updatemssg", data: messageUpdateArgsData)
    }
    
    static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let changereputArgsData = DataWriterValue(hex: changereputArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "changereput", data: changereputArgsData)
    }
    
    static func reblog(args: EOSTransaction.ReblogArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let reblogArgsData = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsPublish, name: "reblog", data: reblogArgsData)
    }
    
    // MARK: - Contract `gls.vesting`
    static func publish(transferArgs: EOSTransaction.TransferArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let transferArgsData = DataWriterValue(hex: transferArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsVesting, name: "transfer", data: transferArgsData)
    }
    
    // MARK: - Contract `gls.social`
    static func updateUserProfile(pinArgs: EOSTransaction.UserProfilePinArgs, isUnpin: Bool) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let pinArgsData = DataWriterValue(hex: pinArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: isUnpin ? "unpin": "pin", data: pinArgsData)
    }
    
    static func updateUserProfile(blockArgs: EOSTransaction.UserProfileBlockArgs, isUnblock: Bool) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let blockArgsData = DataWriterValue(hex: blockArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: isUnblock ? "unblock": "block", data: blockArgsData)
    }
    
    static func update(userProfileMetaArgs: EOSTransaction.UserProfileUpdatemetaArgs) -> Single<ChainResponse<TransactionCommitted>> {
        Logger.log(message: "\nuserProfileMetaArgs: \n\(userProfileMetaArgs.convertToJSON())\n", event: .debug)
        
        // Prepare data
        let userProfileUpdatemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: "updatemeta", data: userProfileUpdatemetaArgsData)
    }
    
    static func delete(userProfileMetaArgs: EOSTransaction.UserProfileDeleteArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let userProfileDeletemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsSocial, name: "deletemeta", data: userProfileDeletemetaArgsData)
    }
    
    // MARK: - Contract `gls.ctrl`
    static func reg(witnessArgs: EOSTransaction.RegwitnessArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let regwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "regwitness", data: regwithessArgsData)
    }
    
    static func vote(witnessArgs: EOSTransaction.VotewitnessArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let votewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "votewitness", data: votewithessArgsData)
    }
    
    static func unvote(witnessArgs: EOSTransaction.UnvotewitnessArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let unvotewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "unvotewitn", data: unvotewithessArgsData)
    }
    
    static func unreg(witnessArgs: EOSTransaction.UnregwitnessArgs) -> Single<ChainResponse<TransactionCommitted>> {
        // Prepare data
        let unregwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .glsCtrl, name: "unregwitness", data: unregwithessArgsData)
    }
}

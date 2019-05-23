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
    static func create(message:         String,
                       headline:        String = "",
                       parentData:      ParentData? = nil,
                       tags:            [EOSTransaction.Tags],
                       jsonMetaData:    String?) -> Single<ChainResponse<TransactionCommitted>> {
        // Check user authorize
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return .error(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        return chainInfo
            .flatMap({ (info) -> Single<ChainResponse<TransactionCommitted>> in
                let messageTransaction = EOSTransaction(chainApi: EOSManager.chainApi)
                
                let messageTransactionAuthorizationAbi = TransactionAuthorizationAbi(
                    actor: AccountNameWriterValue(name: userNickName),
                    permission: AccountNameWriterValue(name: "active"))
                
                let refBlockNum: UInt64 = UInt64(info.head_block_num)
                
                let messageCreateArgs = EOSTransaction.MessageCreateArgs(
                    authorValue:        userNickName,
                    parentDataValue:    parentData,
                    refBlockNumValue:   refBlockNum,
                    headermssgValue:    headline,
                    bodymssgValue:      message,
                    tagsValues:         tags,
                    jsonmetadataValue:  jsonMetaData)
                
                // JSON
                Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
                
                let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
                
                let messageCreateActionAbi = ActionAbi(
                    account:         AccountNameWriterValue(name:    "gls.publish"),
                    name:            AccountNameWriterValue(name:    "createmssg"),
                    authorization:   [messageTransactionAuthorizationAbi],
                    data:            messageCreateArgsData)
                
                let privateKey = try EOSPrivateKey(base58: userActiveKey)
                
                return messageTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageCreateActionAbi], authorizingPrivateKey: privateKey)
                    .map {response -> ChainResponse<TransactionCommitted> in
                        if !response.success {throw ErrorAPI.blockchain(message: response.errorBody!)}
                        return response
                    }
            })
    }
    
    
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
        guard let userNickName = Config.currentUser.nickName,
            let userActiveKey = Config.currentUser.activeKey else {
                return .error(ErrorAPI.requestFailed(message: "Unauthorized"))
        }
        
        let messageTransaction = EOSTransaction(chainApi: EOSManager.chainApi)
        
        let messageTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:    userNickName),
                                                                             permission:    AccountNameWriterValue(name:    "active"))
        
        let messageDeleteArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        let messageDeleteActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                               name:            AccountNameWriterValue(name:    "deletemssg"),
                                               authorization:   [messageTransactionAuthorizationAbi],
                                               data:            messageDeleteArgsData)
        
        do {
            let privateKey = try EOSPrivateKey(base58: userActiveKey)
            
            return Completable.create {completable in
                return messageTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageDeleteActionAbi], authorizingPrivateKey: privateKey)
                    .subscribe(onSuccess: { (response) in
                        if response.success {
                            completable(.completed)
                            return
                        }
                        completable(.error(ErrorAPI.requestFailed(message: response.errorBody!)))
                    }, onError: { (error) in
                        completable(.error(error))
                    })
            }
        } catch {
            return .error(error)
        }
    }
}

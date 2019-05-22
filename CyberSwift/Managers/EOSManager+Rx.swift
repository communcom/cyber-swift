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

extension EOSManager {
    static func rx_delete(messageArgs: EOSTransaction.MessageDeleteArgs) -> Completable {
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

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
import RxBlocking

public enum VoteActionType: String {
    case unvote     =   "unvote"
    case upvote     =   "upvote"
    case downvote   =   "downvote"
}

class EOSManager {
    // MARK: - Properties
    static let chainApi     =   ChainApiFactory.create(rootUrl: Config.blockchain_API_URL)
    static let historyApi   =   HistoryApiFactory.create(rootUrl: Config.blockchain_API_URL)
    
    /// MARK: - CHAIN
    static func getChainInfo(responseResult:    @escaping (Info) -> Void,
                             responseError:     @escaping (ErrorAPI) -> Void) {
        _ = self.chainApi.getInfo().subscribe(onSuccess: { response in
            if let info = response.body {
                responseResult(info)
            }
        },
                                              onError: { error in
                                                responseError(ErrorAPI.invalidData(message: "\(error.localizedDescription)"))
        })
    }
    
    ///
    static func getChainInfo() {
        _ = self.chainApi.getInfo().subscribe(onSuccess: { response in
            if let info = response.body {
                self.getChain(blockNumberID: info.head_block_id)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                Logger.log(message: "\(String(describing: httpErrorResponse.bodyString))", event: .error)
            }
        })
    }
    
    ///
    static func getChain(blockNumberID: String) {
        _ = self.chainApi.getBlock(body: BlockNumOrId(block_num_or_id: blockNumberID)).subscribe(onSuccess: { response in
            if let info = response.body {
                Logger.log(message: "info = \(info)", event: .debug)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                Logger.log(message: "\(String(describing: httpErrorResponse.bodyString))", event: .error)
            }
        })
    }
    
    ///
    static func getAccount(nickName:    String,
                           completion:  @escaping (HttpResponse<Account>?, Error?) -> Void) {
        _ = self.chainApi.getAccount(body: AccountName(account_name: nickName)).subscribe(onSuccess: { response in
            if let info = response.body {
                Logger.log(message: "info = \(info)", event: .debug)
                completion(response, nil)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                Logger.log(message: "\(String(describing: httpErrorResponse.bodyString))", event: .error)
                completion(nil, error)
            }
        })
    }
    
    /// Receive secret key
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

    
    //  MARK: - Contract `gls.publish`
    /// Action `newaccount`
    static func createNewAccount(nickName:          String,
                                 responseResult:    @escaping (ChainResponse<TransactionCommitted>) -> Void,
                                 responseError:     @escaping (Error) -> Void) {
        guard let userID = Config.currentUser?.id, let userActiveKey = Config.currentUser?.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        let createNewAccountTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let createNewAccountTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:   userID),
                                                                                      permission:    AccountNameWriterValue(name:   "active"))
        
        do {
            let currentUserPublicKey = try EOSPublicKey(base58: userActiveKey)
            
            let owner = AccountRequiredAuthAbi(threshold:   1,
                                               keys:        [AccountKeyAbi(key:     PublicKeyWriterValue(publicKey:         currentUserPublicKey,
                                                                                                         isCurveParamK1:    true),
                                                                           weight:  1)
                ],
                                               accounts:    StringCollectionWriterValue(value: []),
                                               waits:       StringCollectionWriterValue(value: []))
            
            let createNewAccountArgs = NewAccountArgs(creator:      AccountNameWriterValue(name:    userID),
                                                      name:         AccountNameWriterValue(name:    userID),
                                                      owner:        owner,
                                                      active:       owner)
            
            let createNewAccountArgsData = DataWriterValue(hex: createNewAccountArgs.toHex())
            
            let createNewAccountActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                                      name:            AccountNameWriterValue(name:    "newaccount"),
                                                      authorization:   [createNewAccountTransactionAuthorizationAbi],
                                                      data:            createNewAccountArgsData)
            
            do {
                let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
                
                if let response = try createNewAccountTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [createNewAccountActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                    if response.success {
                        responseResult(response)
                    }
                }
            } catch {
                responseError(error)
            }
        } catch {
            responseError(error)
        }
    }
    
    // MARK: - HISTORY
    static func getTransaction(blockNumberHint: String) {
        _ = self.historyApi.getTransaction(body: GetTransaction(id: blockNumberHint)).subscribe(onSuccess: { response in
            if let info = response.body {
                Logger.log(message: "info = \(info)", event: .debug)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                Logger.log(message: "\(String(describing: httpErrorResponse.bodyString))", event: .error)
            }
        })
    }
}

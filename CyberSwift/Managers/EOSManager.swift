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
//

import eosswift
import Foundation
import RxBlocking

public enum VoteType: String {
    case unvote     =   "unvote"
    case upvote     =   "upvote"
    case downvote   =   "downvote"
}

class EOSManager {
    // MARK: - Properties
    static let chainApi = ChainApiFactory.create(rootUrl: Config.CHAIN_CYBERWAY_API_BASE_URL)
    static let historyApi = HistoryApiFactory.create(rootUrl: Config.CHAIN_CYBERWAY_API_BASE_URL)
    
    
    // MARK: - Class Functions
    static func createPairKeys() {
        // Private key from encoded string
        let privateKey = try! EOSPrivateKey(base58: Config.postingKeyDestroyer2k)
        print("privateKey = \(privateKey.base58)")
    }
    
    
    /// CHAIN
    static func getChainInfo(completion: @escaping (Info?, Error?) -> Void) {
        _ = self.chainApi.getInfo().subscribe(onSuccess: { response in
            if let info = response.body {
                completion(info, nil)
            }
        }, onError: { error in
            completion(nil, error)
        })
    }
    
    //
    static func getChainInfo() {
        _ = self.chainApi.getInfo().subscribe(onSuccess: { response in
            if let info = response.body {
                self.getChain(blockNumberID: info.head_block_id)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                print("\(String(describing: httpErrorResponse.bodyString))")
            }
        })
    }
    
    //
    static func getChain(blockNumberID: String) {
        _ = self.chainApi.getBlock(body: BlockNumOrId(block_num_or_id: blockNumberID)).subscribe(onSuccess: { response in
            if let info = response.body {
                print("info = \(info)")
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                print("\(String(describing: httpErrorResponse.bodyString))")
            }
        })
    }
    
    //
    static func getAccount(nickName: String, completion: @escaping (HttpResponse<Account>?, Error?) -> Void) {
        _ = self.chainApi.getAccount(body: AccountName(account_name: nickName)).subscribe(onSuccess: { response in
            if let info = response.body {
                print("info = \(info)")
                completion(response, nil)
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                print("\(String(describing: httpErrorResponse.bodyString))")
                completion(nil, error)
            }
        })
    }
    
    // EOS: contract `gls.publish`, action `newaccount`
    static func createNewAccount(nickName: String, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let createNewAccountTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let createNewAccountTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:   userNickName),
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
            
            let createNewAccountArgs = NewAccountArgs(creator:      AccountNameWriterValue(name:    userNickName),
                                                      name:         AccountNameWriterValue(name:    userNickName),
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
                        completion(response, nil)
                    }
                }
            } catch {
                completion(nil, error)
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // Receive secret key
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
    
    // EOS: contract `gls.publish`, action `createmssg`
    static func publish(message: String, headline: String = "", parentData: ParentData? = nil, tags: [EOSTransaction.Tags]?, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        EOSManager.getChainInfo(completion: { (info, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            let messageTransaction = EOSTransaction.init(chainApi: chainApi)
            
            let messageTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:    userNickName),
                                                                                 permission:    AccountNameWriterValue(name:    "active"))
            
            let refBlockNum: UInt64 = UInt64(info!.head_block_num)
            
            let messageCreateArgs = EOSTransaction.MessageCreateArgs(authorValue:               userNickName,
                                                                     parentDataValue:           parentData,
                                                                     refBlockNumValue:          refBlockNum,
                                                                     headermssgValue:           headline,
                                                                     bodymssgValue:             message,
                                                                     tagsValues:                tags ?? [EOSTransaction.Tags()])
            
            // JSON
            print(messageCreateArgs.convertToJSON())
            
            let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
            
            let messageCreateActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                                   name:            AccountNameWriterValue(name:    "createmssg"),
                                                   authorization:   [messageTransactionAuthorizationAbi],
                                                   data:            messageCreateArgsData)
            
            DispatchQueue.main.async {
                do {
                    let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
                    
                    if let response = try messageTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageCreateActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                        if response.success {
                            completion(response, nil)
                        }
                    }
                } catch {
                    completion(nil, error)
                }
            }
        })
    }

    // EOS: contract `gls.publish`, action `deletemssg`
    static func delete(messageArgs: EOSTransaction.MessageDeleteArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let messageTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let messageTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:    userNickName),
                                                                             permission:    AccountNameWriterValue(name:    "active"))
        
        let messageDeleteArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        let messageDeleteActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                               name:            AccountNameWriterValue(name:    "deletemssg"),
                                               authorization:   [messageTransactionAuthorizationAbi],
                                               data:            messageDeleteArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try messageTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageDeleteActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.publish`, action `updatemssg`
    static func update(messageArgs: EOSTransaction.MessageUpdateArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let messageUpdateTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let messageUpdateTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:  userNickName),
                                                                                   permission:    AccountNameWriterValue(name:  "active"))
        
        let messageUpdateArgsData = DataWriterValue(hex: messageArgs.toHex())
        
        let messageUpdateActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                               name:            AccountNameWriterValue(name:    "updatemssg"),
                                               authorization:   [messageUpdateTransactionAuthorizationAbi],
                                               data:            messageUpdateArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try messageUpdateTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageUpdateActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.publish`, actions `upvote`, `downvote`, `unvote`
    static func message(voteType: VoteType, author: String, permlink: String, weight: Int16, refBlockNum: UInt64, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            completion(nil, NSError(domain: "User is not authorized.", code: 401, userInfo: nil))
            return
        }
        
        let voteTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let voteTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:        AccountNameWriterValue(name:    userNickName),
                                                                          permission:   AccountNameWriterValue(name:    "active"))
        
        let voteArgs: Encodable = (voteType == .unvote) ?   EOSTransaction.UnvoteArgs.init(voterValue:          userNickName,
                                                                                           authorValue:         author,
                                                                                           permlinkValue:       permlink,
                                                                                           refBlockNumValue:    refBlockNum) :
            EOSTransaction.UpvoteArgs.init(voterValue:          userNickName,
                                           authorValue:         author,
                                           permlinkValue:       permlink,
                                           refBlockNumValue:    refBlockNum,
                                           weightValue:         weight)
        
        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())
        
        let voteActionAbi = ActionAbi(account:          AccountNameWriterValue(name:    "gls.publish"),
                                      name:             AccountNameWriterValue(name:    voteType.rawValue),
                                      authorization:    [voteTransactionAuthorizationAbi],
                                      data:             voteArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try voteTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [voteActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    // Update user profile reputation
                    if voteType == .unvote {
                        completion(response, nil)
                    }
                        
                    else {
                        let changereputArgs = EOSTransaction.UserProfileChangereputArgs(voterValue: userNickName, authorValue: author, rsharesValue: voteType == .upvote ? 1 : -1)
                        
                        self.updateUserProfile(changereputArgs: changereputArgs) { (response, error) in
                            guard error == nil else {
                                completion(nil, error)
                                return
                            }
                            
                            completion(response, nil)
                        }
                    }
                }
            }
        } catch {
            completion(nil, error)
        }
    }

    // EOS: contract `gls.vesting`, action `transfer`
    static func publish(transferArgs: EOSTransaction.TransferArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let transferTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let transferTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:   userNickName),
                                                                              permission:    AccountNameWriterValue(name:   "active"))
        
        let transferArgsData = DataWriterValue(hex: transferArgs.toHex())
        
        let transferActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.vesting"),
                                          name:            AccountNameWriterValue(name:    "transfer"),
                                          authorization:   [transferTransactionAuthorizationAbi],
                                          data:            transferArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try transferTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [transferActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.social`, actions `pin`, `unpin`
    static func updateUserProfile(pinArgs: EOSTransaction.UserProfilePinArgs, isUnpin: Bool, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let userProfilePinTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let userProfilePinTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:     userNickName),
                                                                                    permission:    AccountNameWriterValue(name:     "active"))
        
        let pinArgsData = DataWriterValue(hex: pinArgs.toHex())
        
        let pinActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                     name:            AccountNameWriterValue(name:    isUnpin ? "unpin" : "pin"),
                                     authorization:   [userProfilePinTransactionAuthorizationAbi],
                                     data:            pinArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfilePinTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [pinActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.social`, actions `block`, `unblock`
    static func updateUserProfile(blockArgs: EOSTransaction.UserProfileBlockArgs, isUnblock: Bool, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let userProfileBlockTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let userProfileBlockTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:   userNickName),
                                                                                      permission:    AccountNameWriterValue(name:   "active"))
        
        let blockArgsData = DataWriterValue(hex: blockArgs.toHex())
        
        let blockActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                       name:            AccountNameWriterValue(name:    isUnblock ? "unblock" : "block"),
                                       authorization:   [userProfileBlockTransactionAuthorizationAbi],
                                       data:            blockArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfileBlockTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [blockActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.publish`, action `changereput`
    private static func updateUserProfile(changereputArgs: EOSTransaction.UserProfileChangereputArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        let userProfileChangereputTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let userProfileChangereputTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:     userNickName),
                                                                                            permission:    AccountNameWriterValue(name:     "active"))
        
        let changereputArgsData = DataWriterValue(hex: changereputArgs.toHex())
        
        let changereputActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                             name:            AccountNameWriterValue(name:    "changereput"),
                                             authorization:   [userProfileChangereputTransactionAuthorizationAbi],
                                             data:            changereputArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfileChangereputTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [changereputActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.social`, action `updatemeta`
    static func updateUserProfile(metaArgs: EOSTransaction.UserProfileUpdatemetaArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else { return }
        
        // JSON
        print(metaArgs.convertToJSON())
        
        let userProfileUpdatemetaTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let userProfileUpdateTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:  userNickName),
                                                                                       permission:    AccountNameWriterValue(name:  "active"))
        
        let updatemetaArgsData = DataWriterValue(hex: metaArgs.toHex())
        
        let updateActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                        name:            AccountNameWriterValue(name:    "updatemeta"),
                                        authorization:   [userProfileUpdateTransactionAuthorizationAbi],
                                        data:            updatemetaArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfileUpdatemetaTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [updateActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    // EOS: contract `gls.social`, action `deletemeta`
    static func deleteUserProfile(metaArgs: EOSTransaction.UserProfileDeleteArgs, completion: @escaping (ChainResponse<TransactionCommitted>?, Error?) -> Void) {
        let userProfileDeletemetaTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let userProfileDeleteTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: Config.accountNickTest),
                                                                                       permission:    AccountNameWriterValue(name: "active"))
        
        let deletemetaArgsData = DataWriterValue(hex: metaArgs.toHex())
        
        let deleteActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                        name:            AccountNameWriterValue(name:    "deletemeta"),
                                        authorization:   [userProfileDeleteTransactionAuthorizationAbi],
                                        data:            deletemetaArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: Config.activeKeyTest)
            
            if let response = try userProfileDeletemetaTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [deleteActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    completion(response, nil)
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    
    /// HISTORY
    static func getTransaction(blockNumberHint: String) {
        _ = self.historyApi.getTransaction(body: GetTransaction(id: blockNumberHint)).subscribe(onSuccess: { response in
            if let info = response.body {
                print("info = \(info)")
            }
        }, onError: { error in
            if let httpErrorResponse = error as? HttpErrorResponse<ChainError> {
                print("\(String(describing: httpErrorResponse.bodyString))")
            }
        })
    }
    
    
    /// DBSIZE
}

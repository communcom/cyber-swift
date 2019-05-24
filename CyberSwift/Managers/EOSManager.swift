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
    
    
    // MARK: - Class Functions
    static func createPairKeys() {
        // Private key from encoded string
        let privateKey = try! EOSPrivateKey(base58: Config.postingKeyDestroyer2k)
        Logger.log(message: "\nprivateKey: \n\(privateKey.base58)\n", event: .debug)
    }
    
    
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
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
    
    /// Action `createmssg`
    // https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi#L238-L291
    static func create(message:         String,
                       headline:        String = "",
                       parentData:      ParentData? = nil,
                       tags:            [EOSTransaction.Tags],
                       jsonMetaData:    String?,
                       responseResult:  @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:   @escaping (ErrorAPI) -> Void) {
        // Check user authorize
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
    
        let messageTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let messageTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:    userNickName),
                                                                             permission:    AccountNameWriterValue(name:    "active"))
        
        let messageCreateArgs = EOSTransaction.MessageCreateArgs(authorValue:               userNickName,
                                                                 parentDataValue:           parentData,
                                                                 headermssgValue:           headline,
                                                                 bodymssgValue:             message,
                                                                 tagsValues:                tags,
                                                                 jsonmetadataValue:         jsonMetaData)
        
        // JSON
        Logger.log(message: messageCreateArgs.convertToJSON(), event: .debug)
        
        let messageCreateArgsData = DataWriterValue(hex: messageCreateArgs.toHex())
        
        let messageCreateActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                               name:            AccountNameWriterValue(name:    "createmssg"),
                                               authorization:   [messageTransactionAuthorizationAbi],
                                               data:            messageCreateArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try messageTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [messageCreateActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                } else {
                    throw ErrorAPI.requestFailed(message: response.errorBody!)
                }
            }
        } catch {
            responseError(ErrorAPI.responseUnsuccessful(message: "\(error.localizedDescription)"))
        }
    }


    /// Action `deletemssg`
    static func delete(messageArgs:     EOSTransaction.MessageDeleteArgs,
                       responseResult:  @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:   @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                } else {
                    throw ErrorAPI.requestFailed(message: response.errorBody!)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    /// Action `updatemssg`
    static func update(messageArgs:     EOSTransaction.MessageUpdateArgs,
                       responseResult:  @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:   @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    /// Action `changereput`
    static func updateUserProfile(changereputArgs:  EOSTransaction.UserProfileChangereputArgs,
                                  responseResult:   @escaping (ChainResponse<TransactionCommitted>) -> Void,
                                  responseError:    @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }

    /// Actions `upvote`, `downvote`, `unvote`
    static func message(voteActionType:     VoteActionType,
                        author:             String,
                        permlink:           String,
                        weight:             Int16,
                        responseResult:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                        responseError:      @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        let voteTransaction = EOSTransaction.init(chainApi: chainApi)
        
        let voteTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:        AccountNameWriterValue(name:    userNickName),
                                                                          permission:   AccountNameWriterValue(name:    "active"))
        
        let voteArgs: Encodable = (voteActionType == .unvote) ? EOSTransaction.UnvoteArgs.init(voterValue:          userNickName,
                                                                                               authorValue:         author,
                                                                                               permlinkValue:       permlink)   :
                                                                EOSTransaction.UpvoteArgs.init(voterValue:          userNickName,
                                                                                               authorValue:         author,
                                                                                               permlinkValue:       permlink,
                                                                                               weightValue:         weight)
        
        let voteArgsData = DataWriterValue(hex: voteArgs.toHex())
        
        let voteActionAbi = ActionAbi(account:          AccountNameWriterValue(name:    "gls.publish"),
                                      name:             AccountNameWriterValue(name:    voteActionType.rawValue),
                                      authorization:    [voteTransactionAuthorizationAbi],
                                      data:             voteArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try voteTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [voteActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    // Update user profile reputation
                    if voteActionType == .unvote {
                        responseResult(response)
                    }
                        
                    else {
                        let changereputArgs = EOSTransaction.UserProfileChangereputArgs(voterValue: userNickName, authorValue: author, rsharesValue: voteActionType == .upvote ? 1 : -1)
                        
                        self.updateUserProfile(changereputArgs: changereputArgs,
                                               responseResult: { response in
                                                responseResult(response)
                        },
                                               responseError: { error in
                                                responseError(error)
                        })
                    }
                } else {
                    throw ErrorAPI.requestFailed(message: response.errorBody!)
                }
            }
        } catch {
            responseError(error)
        }
    }

    /// Action `reblog`
    static func reblog(args:            EOSTransaction.ReblogArgs,
                       responseResult:  @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:   @escaping (ErrorAPI) -> Void) {
        // Check user authorize
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        let reblogTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let reblogTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:     userNickName),
                                                                            permission:    AccountNameWriterValue(name:     "active"))
        
        let reblogArgsData = DataWriterValue(hex: args.toHex())
        
        let reblogActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.publish"),
                                        name:            AccountNameWriterValue(name:    "reblog"),
                                        authorization:   [reblogTransactionAuthorizationAbi],
                                        data:            reblogArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try reblogTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [reblogActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
            }
        } catch {
            responseError(ErrorAPI.responseUnsuccessful(message: "\(error.localizedDescription)"))
        }
    }

    
    //  MARK: - Contract `gls.vesting`
    /// Action `transfer`
    static func publish(transferArgs:       EOSTransaction.TransferArgs,
                        responseResult:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                        responseError:      @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    
    //  MARK: - Contract `gls.social`
    /// Actions `pin`, `unpin`
    static func updateUserProfile(pinArgs:          EOSTransaction.UserProfilePinArgs,
                                  isUnpin:          Bool,
                                  responseResult:   @escaping (ChainResponse<TransactionCommitted>) -> Void,
                                  responseError:    @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    /// Actions `block`, `unblock`
    static func updateUserProfile(blockArgs:        EOSTransaction.UserProfileBlockArgs,
                                  isUnblock:        Bool,
                                  responseResult:   @escaping (ChainResponse<TransactionCommitted>) -> Void,
                                  responseError:    @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
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
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    /// Action `updatemeta`
    static func update(userProfileMetaArgs:     EOSTransaction.UserProfileUpdatemetaArgs,
                       responseResult:          @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:           @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        // JSON
        Logger.log(message: "\nuserProfileMetaArgs: \n\(userProfileMetaArgs.convertToJSON())\n", event: .debug)
        
        let userProfileUpdatemetaTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let userProfileUpdateTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name:  userNickName),
                                                                                       permission:    AccountNameWriterValue(name:  "active"))
        
        let userProfileUpdatemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        let userProfileUpdateActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                                   name:            AccountNameWriterValue(name:    "updatemeta"),
                                                   authorization:   [userProfileUpdateTransactionAuthorizationAbi],
                                                   data:            userProfileUpdatemetaArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfileUpdatemetaTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [userProfileUpdateActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    // Action `deletemeta`
    static func delete(userProfileMetaArgs:     EOSTransaction.UserProfileDeleteArgs,
                       responseResult:          @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:           @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }

        let userProfileDeletemetaTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let userProfileDeleteTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: userNickName),
                                                                                       permission:    AccountNameWriterValue(name: "active"))
        
        let userProfileDeletemetaArgsData = DataWriterValue(hex: userProfileMetaArgs.toHex())
        
        let userProfileDeleteActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.social"),
                                                   name:            AccountNameWriterValue(name:    "deletemeta"),
                                                   authorization:   [userProfileDeleteTransactionAuthorizationAbi],
                                                   data:            userProfileDeletemetaArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try userProfileDeletemetaTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [userProfileDeleteActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                } else {
                    throw ErrorAPI.requestFailed(message: response.errorBody!)
                }
            }
        } catch {
            responseError(error)
        }
    }

    
    //  MARK: - Contract `gls.ctrl`
    /// Action `regwitness` (1)
    static func reg(witnessArgs:        EOSTransaction.RegwitnessArgs,
                    responseResult:     @escaping (ChainResponse<TransactionCommitted>) -> Void,
                    responseError:      @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        let regwithessTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let regwithessTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: userNickName),
                                                                                permission:    AccountNameWriterValue(name: "active"))
        
        let regwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        let regwithessActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.ctrl"),
                                            name:            AccountNameWriterValue(name:    "regwitness"),
                                            authorization:   [regwithessTransactionAuthorizationAbi],
                                            data:            regwithessArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try regwithessTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [regwithessActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }

    // Action `votewitness` (2)
    static func vote(witnessArgs:       EOSTransaction.VotewitnessArgs,
                     responseResult:    @escaping (ChainResponse<TransactionCommitted>) -> Void,
                     responseError:     @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }

        let votewithessTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let votewithessTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: userNickName),
                                                                                 permission:    AccountNameWriterValue(name: "active"))
        
        let votewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        let votewithessActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.ctrl"),
                                             name:            AccountNameWriterValue(name:    "votewitness"),
                                             authorization:   [votewithessTransactionAuthorizationAbi],
                                             data:            votewithessArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try votewithessTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [votewithessActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }

    // Action `unvotewitn` (3)
    static func unvote(witnessArgs:         EOSTransaction.UnvotewitnessArgs,
                       responseResult:      @escaping (ChainResponse<TransactionCommitted>) -> Void,
                       responseError:       @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }
        
        let unvotewithessTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let unvotewithessTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: userNickName),
                                                                                   permission:    AccountNameWriterValue(name: "active"))
        
        let unvotewithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        let unvotewithessActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.ctrl"),
                                               name:            AccountNameWriterValue(name:    "unvotewitn"),
                                               authorization:   [unvotewithessTransactionAuthorizationAbi],
                                               data:            unvotewithessArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try unvotewithessTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [unvotewithessActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
            }
        } catch {
            responseError(error)
        }
    }
    
    // Action `unregwitness` (4)
    static func unreg(witnessArgs:          EOSTransaction.UnregwitnessArgs,
                      responseResult:       @escaping (ChainResponse<TransactionCommitted>) -> Void,
                      responseError:        @escaping (Error) -> Void) {
        guard let userNickName = Config.currentUser.nickName, let userActiveKey = Config.currentUser.activeKey else {
            return responseError(ErrorAPI.invalidData(message: "Unauthorized"))
        }

        let unregwithessTransaction = EOSTransaction.init(chainApi: EOSManager.chainApi)
        
        let unregwithessTransactionAuthorizationAbi = TransactionAuthorizationAbi(actor:         AccountNameWriterValue(name: userNickName),
                                                                                  permission:    AccountNameWriterValue(name: "active"))
        
        let unregwithessArgsData = DataWriterValue(hex: witnessArgs.toHex())
        
        let unregwithessActionAbi = ActionAbi(account:         AccountNameWriterValue(name:    "gls.ctrl"),
                                              name:            AccountNameWriterValue(name:    "unregwitness"),
                                              authorization:   [unregwithessTransactionAuthorizationAbi],
                                              data:            unregwithessArgsData)
        
        do {
            let privateKey = try EOSPrivateKey.init(base58: userActiveKey)
            
            if let response = try unregwithessTransaction.push(expirationDate: Date.defaultTransactionExpiry(expireSeconds: Config.expireSeconds), actions: [unregwithessActionAbi], authorizingPrivateKey: privateKey).asObservable().toBlocking().first() {
                if response.success {
                    responseResult(response)
                }
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

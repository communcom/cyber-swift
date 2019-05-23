//
//  RestAPIManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension RestAPIManager: ReactiveCompatible {}

extension Reactive where Base: RestAPIManager {
    //  MARK: - Contract `gls.publish`
    public func vote(voteType:       VoteType,
                     author:         String,
                     permlink:       String,
                     weight:         Int16? = 0,
                     refBlockNum:    UInt64 = 0) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        return EOSManager.rx.vote(voteType:        voteType,
                                  author:          author,
                                  permlink:        permlink,
                                  weight:          voteType == .unvote ? 0 : 10_000,
                                  refBlockNum:     refBlockNum)
    }
    
    public func create(message:             String,
                       headline:            String? = "",
                       parentData:          ParentData? = nil,
                       tags:                [String]?,
                       metaData:            String?) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        return EOSManager.rx.create(
            message:          message,
            headline:         headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
            tags:             arrayTags,
            jsonMetaData:     metaData)
    }
    
    public func deleteMessage(author: String, permlink: String, refBlockNum: UInt64) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue:           author,
                                                                 messagePermlink:       permlink,
                                                                 refBlockNumValue:      refBlockNum)
        return EOSManager.rx.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(author:       String?,
                              permlink:     String,
                              message:      String,
                              parentData:   ParentData?,
                              refBlockNum:  UInt64) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(authorValue:           author ?? Config.currentUser.nickName ?? "Cyberway",
                                                                 messagePermlink:       permlink,
                                                                 parentDataValue:       parentData,
                                                                 refBlockNumValue:      refBlockNum,
                                                                 bodymssgValue:         message)
        return EOSManager.rx.update(messageArgs: messageUpdateArgs)
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       refBlockNum:         UInt64) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   refBlockNumValue:    refBlockNum,
                                                   reblogerValue:       rebloger)
        
        return EOSManager.rx.reblog(args: reblogArgs)
    }
}

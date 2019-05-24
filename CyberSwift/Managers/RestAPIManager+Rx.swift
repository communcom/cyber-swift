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
    public func vote(voteType:       VoteActionType,
                     author:         String,
                     permlink:       String,
                     weight:         UInt16 = 0) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        return EOSManager.rx.vote(voteType:     voteType,
                                  author:       author,
                                  permlink:     permlink,
                                  weight:       voteType == .unvote ? 0 : 10_000)
    }
    
    public func create(message:             String,
                       headline:            String? = nil,
                       parentData:          ParentData? = nil,
                       tags:                [String]?,
                       metaData:            String?) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let userNickName = Config.currentUser.nickName, let _ = Config.currentUser.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        let messageCreateArgs = EOSTransaction.MessageCreateArgs(
            authorValue:        userNickName,
            parentDataValue:    parentData,
            headermssgValue:    headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
            bodymssgValue:      message,
            tagsValues:         arrayTags,
            jsonmetadataValue:  metaData)
        
        return EOSManager.rx.create(messageCreateArgs: messageCreateArgs)
    }
    
    public func deleteMessage(author: String, permlink: String, refBlockNum: UInt64) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue: author, messagePermlink: permlink)
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
                                                                 bodymssgValue:         message)
        return EOSManager.rx.update(messageArgs: messageUpdateArgs)
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       headermssg:          String,
                       bodymssg:            String,
                       refBlockNum:         UInt64) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        return EOSManager.rx.reblog(args: reblogArgs)
    }
}

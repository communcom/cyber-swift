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
}

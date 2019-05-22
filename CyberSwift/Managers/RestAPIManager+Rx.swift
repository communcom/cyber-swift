//
//  RestAPIManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    static func rx_deleteMessage(author: String, permlink: String, refBlockNum: UInt64) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue:           author,
                                                                 messagePermlink:       permlink,
                                                                 refBlockNumValue:      refBlockNum)
        return EOSManager.rx_delete(messageArgs: messageDeleteArgs)
    }
}

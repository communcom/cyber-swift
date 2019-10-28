//
//  commun.list.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension EOSManager {
    static func followCommunity(_ followArgs: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        // Prepare data
        let followArgsData = DataWriterValue(hex: followArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .comnList, name: "follow", data: followArgsData)
    }
}

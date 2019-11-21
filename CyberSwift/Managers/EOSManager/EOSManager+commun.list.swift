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
        return pushAuthorized(account: .list, name: "follow", data: followArgsData)
    }
    
    static func unfollowCommunity(_ unfollowArgs: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        // Prepare data
        let unfollowArgsData = DataWriterValue(hex: unfollowArgs.toHex())
        
        // Send transaction
        return pushAuthorized(account: .list, name: "unfollow", data: unfollowArgsData)
    }
    
    static func hideCommunity(_ args: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return pushAuthorized(account: .list, name: "hide", data: data)
    }
    
    static func unhideCommunity(_ args: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        // Prepare data
        let data = DataWriterValue(hex: args.toHex())
        
        // Send transaction
        return pushAuthorized(account: .list, name: "unhide", data: data)
    }
}

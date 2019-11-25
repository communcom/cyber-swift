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
        return pushAuthorized(account: .list, name: "follow", args: followArgs)
    }
    
    static func unfollowCommunity(_ unfollowArgs: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        return pushAuthorized(account: .list, name: "unfollow", args: unfollowArgs)
    }
    
    static func hideCommunity(_ args: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        return pushAuthorized(account: .list, name: "hide", args: args)
    }
    
    static func unhideCommunity(_ args: EOSTransaction.CommunListFollowArgs) -> Single<String> {
        return pushAuthorized(account: .list, name: "unhide", args: args)
    }
}

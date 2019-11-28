//
//  ResponseAPIContentGetSubscriptionsItem.swift
//  Commun
//
//  Created by Chung Tran on 10/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentGetSubscriptionsItem: IdentifiableType {
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
}

extension ResponseAPIContentGetSubscriptionsUser: IdentifiableType {
    public var identity: String {
        return userId + "/" + username
    }
}

extension ResponseAPIContentGetSubscriptionsCommunity: IdentifiableType {
    public var identity: String {
        return communityId + "/" + name
    }
}

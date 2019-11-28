//
//  ResponseAPIContentGetBlacklistItem.swift
//  Commun
//
//  Created by Chung Tran on 11/13/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentGetBlacklistItem: IdentifiableType {
    public var identity: String {
        switch self {
        case .user(let user):
            return user.identity
        case .community(let community):
            return community.identity
        }
    }
}

extension ResponseAPIContentGetBlacklistUser: IdentifiableType {
    public var identity: String {
        return userId + "/" + username
    }
}

extension ResponseAPIContentGetBlacklistCommunity: IdentifiableType {
    public var identity: String {
        return communityId + "/" + name
    }
}

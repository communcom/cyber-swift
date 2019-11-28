//
//  ResponseAPIContentGetCommunity.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentGetCommunity: IdentifiableType {
    public var identity: String {
        return communityId + "/" + name
    }
}

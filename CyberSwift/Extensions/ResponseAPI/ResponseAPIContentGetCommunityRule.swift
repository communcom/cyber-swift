//
//  ResponseAPIContentGetCommunityRule.swift
//  Commun
//
//  Created by Chung Tran on 11/5/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentGetCommunityRule: IdentifiableType {
    public var identity: String {
        return id ?? "\(Int.random(in: 0..<100))"
    }
}

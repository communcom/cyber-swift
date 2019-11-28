//
//  ResponseAPIContentResolveProfile.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentResolveProfile: IdentifiableType {
    public var identity: String {
        return userId + "/" + username
    }
}

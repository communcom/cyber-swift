//
//  ResponseAPIContentGetLeader.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetLeader: IdentifiableType {
    public var identity: String {
        return userId
    }
}

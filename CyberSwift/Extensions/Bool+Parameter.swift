//
//  Bool+Parameter.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/04/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension Bool {
    var toParam: String {
        return self ? "true" : ""
    }
}

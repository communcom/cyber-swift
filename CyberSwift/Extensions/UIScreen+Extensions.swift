//
//  UIScreen+Extensions.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/23/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension UIScreen {
    public var isSmall: Bool {
        switch UIDevice.current.screenType {
        case .iPhones_5_5s_5c_SE:
            return true
        default:
            return false
        }
    }
}

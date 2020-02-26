//
//  Double.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension Double {
    public var readableString: String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = false
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = (self < 1000) ? 4 : 2
        return formatter.string(from: self as NSNumber) ?? "0"
    }
}

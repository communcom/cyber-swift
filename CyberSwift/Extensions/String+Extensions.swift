//
//  String+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 4/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension String {
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

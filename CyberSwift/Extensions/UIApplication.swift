//
//  UIApplication.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension UIApplication {
    public static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
}

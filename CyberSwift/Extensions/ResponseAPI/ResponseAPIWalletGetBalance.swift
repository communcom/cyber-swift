//
//  ResponseAPIWalletGetBalance.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

public extension ResponseAPIWalletGetBalance {
    static var balanceUpdated: String {"BalanceUpdated"}
    
    static func notifyBalanceUpdated() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)\(balanceUpdated)"), object: nil)
    }
    
    static func observeBalanceUpdated() -> Observable<Void> {
        NotificationCenter.default.rx.notification(.init(rawValue: "\(Self.self)\(balanceUpdated)"))
            .map {_ in ()}
    }
}

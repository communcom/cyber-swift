//
//  RAM+Exchange.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/20/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getCurrenciesFull() -> Single<[ResponseAPIGetCurrency]> {
        let methodAPIType = MethodAPIType.getCurrenciesFull
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

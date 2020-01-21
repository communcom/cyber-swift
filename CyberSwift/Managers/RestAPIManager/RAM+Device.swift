//
//  RAM+Device.swift
//  CyberSwift
//
//  Created by Chung Tran on 1/21/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func deviceSetInfo(timeZoneOffset: Int) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.deviceSetInfo(timeZoneOffset: timeZoneOffset)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

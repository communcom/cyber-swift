//
//  RAM+Config.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getConfig(
        deviceType: String = "phone",
        version: String
    ) -> Single<ResponseAPIGetConfig> {
        let methodAPIType = MethodAPIType.getConfig(deviceType: deviceType, version: version)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

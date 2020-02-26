//
//  RAM+Config.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getConfig() -> Single<ResponseAPIGetConfig> {
        let methodAPIType = MethodAPIType.getConfig
        return executeGetRequest(methodAPIType: methodAPIType)
            .do(onSuccess: { (config) in
                Config.appConfig = config
            })
    }
}

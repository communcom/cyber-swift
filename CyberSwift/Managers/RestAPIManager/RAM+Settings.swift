//
//  RAM+Settings.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/19/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getUserSettings() -> Single<ResponseAPISettingsGetUserSettings> {
        let methodAPIType = MethodAPIType.getUserSettings
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

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
        executeGetRequest(methodGroup: .device, methodName: "setInfo", params: ["timeZoneOffset": timeZoneOffset])
    }
    
    public func deviceSetFcmToken(_ token: String) -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .device, methodName: "setFcmToken", params: ["fcmToken": token])
    }
    
    public func deviceResetFcmToken() -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .device, methodName: "resetFcmToken", params: [:])
    }
}

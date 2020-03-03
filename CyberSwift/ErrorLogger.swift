//
//  ErrorLogger.swift
//  CyberSwift
//
//  Created by Artem Shilin on 02.03.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import Amplitude_iOS

class ErrorLogger {
    static let shared = ErrorLogger()
    typealias Properties = [String: Any]

    private init() {
        #if APPSTORE
            Amplitude.instance()?.initializeApiKey("38406204507945e0941d552f088204fb")
        #endif
    }

    func recordError(_ error: Error, additionalInfo: Properties? = nil) {
        var info: [String: Any] = ["error": error]
        if let additionalInfo = additionalInfo {
            info = info.merging(additionalInfo) { $1 }
        }
        sendEvent(name: "Error", props: info)
    }

    private func sendEvent(name: String, props: Properties) {
        #if APPSTORE
            Amplitude.instance()?.logEvent(name, withEventProperties: props)
        #endif
    }
}

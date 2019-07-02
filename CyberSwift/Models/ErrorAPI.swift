//
//  ErrorAPI.swift
//  CyberSwift
//
//  Created by msm72 on 17.04.2018.
//  Copyright © 2018 Golos.io. All rights reserved.
//

import Foundation
import Localize_Swift

public enum ErrorAPI: Error {
    case disableInternetConnection(message: String?)
    case blockchain(message: String)
    case invalidData(message: String)
    case requestFailed(message: String)
    case jsonParsingFailure(message: String)
    case responseUnsuccessful(message: String)
    case jsonConversionFailure(message: String)
    case signingECCKeychainPostingKeyFailure(message: String)
    case savingKeysError(message: String)
    
    public var caseInfo: (title: String, message: String, code: Int) {
        switch self {
        case .disableInternetConnection(let message):
            return (title: "Error".localized(), message: message ?? "No Internet Connection".localized(), code: 599)
            
        case .blockchain(let message):
            return (title: "Error".localized(), message: message, code: 100)
            
        case .invalidData(let message):
            return (title: "Invalid Data".localized(), message: message, code: 100)
            
        case .requestFailed(let message):
            return (title: "Request Failed".localized(), message: message, code: 100)
            
        case .responseUnsuccessful(let message):
            return (title: "Response Unsuccessful".localized(), message: message, code: 100)
            
        case .jsonParsingFailure(let message):
            return (title: "JSON Parsing Failure".localized(), message: message, code: 100)
            
        case .jsonConversionFailure(let message):
            return (title: "JSON Conversion Failure".localized(), message: message, code: 100)
            
        case .signingECCKeychainPostingKeyFailure(let message):
            return (title: "Keychain Posting Key Failure".localized(), message: message, code: 100)
        case .savingKeysError(let message):
            return (title: "Keychain Saving Failure".localized(), message: message, code: 100)
        }
    }
}

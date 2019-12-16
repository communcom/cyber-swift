//
//  ErrorAPI.swift
//  CyberSwift
//
//  Created by msm72 on 17.04.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import Foundation
import Localize_Swift

public enum ErrorAPI: Error {
    case disableInternetConnection(message: String?)
    case blockchain(message: String)
    case invalidData(message: String)
    case requestFailed(message: String)
    case registrationRequestFailed(message: String, currentStep: String)
    case jsonParsingFailure(message: String)
    case responseUnsuccessful(message: String)
    case jsonConversionFailure(message: String)
    case signingECCKeychainPostingKeyFailure(message: String)
    case savingKeys(message: String)
    case socketDisconnected
    case other(message: String)
    case balanceNotExist(message: String)
    
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
            
        case .registrationRequestFailed(let message, let currentStep):
            return (title: currentStep, message: message, code: 100)

        case .responseUnsuccessful(let message):
            return (title: "Response Unsuccessful".localized(), message: message, code: 100)
            
        case .jsonParsingFailure(let message):
            return (title: "JSON Parsing Failure".localized(), message: message, code: 100)
            
        case .jsonConversionFailure(let message):
            return (title: "JSON Conversion Failure".localized(), message: message, code: 100)
            
        case .signingECCKeychainPostingKeyFailure(let message):
            return (title: "Keychain Posting Key Failure".localized(), message: message, code: 100)
            
        case .savingKeys(let message):
            return (title: "Keychain Saving Failure".localized(), message: message, code: 100)
            
        case .socketDisconnected:
            return (title: "Socket Is Disconnected".localized(), message: "Socket is not connected", code: 100)
            
        case .other(let message):
            return (title: "Other error".localized(), message: message, code: 100)

        case .balanceNotExist(let message):
            return (title: "Request Failed".localized(), message: message, code: 100)
        }
    }
    
    public static var unknown: ErrorAPI {
        return ErrorAPI.other(message: "Unknown error")
    }
    
    public static var unsupported: ErrorAPI {
        return ErrorAPI.other(message: "Unsupported")
    }
    
    public static var unauthorized: ErrorAPI {
        return ErrorAPI.requestFailed(message: "Unauthorized")
    }
    
    public static var couldNotRetrieveChainInfo: ErrorAPI {
        return ErrorAPI.blockchain(message: "Could not retrieve chain info")
    }
}

extension Error {
    public func toErrorAPI() -> ErrorAPI {
        if let error = self as? ErrorAPI {return error}
        return ErrorAPI.other(message: self.localizedDescription)
    }
}

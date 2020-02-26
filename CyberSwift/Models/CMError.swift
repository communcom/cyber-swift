//
//  CommunError.swift
//  CyberSwift
//
//  Created by Chung Tran on 2/26/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public enum ErrorMessage: String {
    case balanceNotExist = "balance does not exist"
    case bodyIsInvalid = "body is invalid"
    case couldNotCreateUserId = "could not create user id"
    case couldNotResizeImage = "could not resize image"
    case couldNotRetrieveChainInfo = "could not retrieve chain info"
    case invalidStepTaken = "Invalid step taken"
    case jsonConversionFailed = "JSON conversion failed"
    case jsonParsingFailed = "JSON parsing failed"
    case messageIdNotFound = "message id not found"
    case needUpdateApplicationVersion = "Need update application version"
    case noInternetConnection = "no internet connection"
    case phoneMissing = "phone missing"
    case postInfoIsMissing = "post info is missing"
    case postNotFound = "post not found"
    case requestHasTimedOut = "request has timed out"
    case secretKeyNotFound = "secret key not found"
    case encodingRequestFailed = "encoding request failed"
    case uploadingImageFailed = "uploading image failed" // POST Request Failed
//    case unauthorizedRequestAccessDenied = "Unauthorized request: access denied"
    case accountHasBeenRegistered = "account has already been registered"
    case userIdOrActiveKeyMissing = "userId or activeKey missing"
    case userIdOrUsernameIsMissing = "userID or username is missing"
    case userNotFound = "user not found"
    case unsupportedDataType = "unsupported data type"
    case unsupportedTypeOfPost = "unsupported type of post"
    case youMustSubscribeToAtLeast3Communities = "you must subscribe to at least 3 communities"
}

public enum CMError: Error, Equatable, CustomStringConvertible {
    // MARK: - network errors
    case noConnection
    
    // MARK: - general request errors
    case userNotFound
    case unauthorized(message: String? = nil)
    case secretVerificationFailed
    
    case invalidRequest(message: String? = nil) // requestFailed
    case invalidResponse(message: String? = nil, responseString: String? = nil) // responseUnsuccessful ErrorAPI.jsonConversionFailure(message: "JSON Conversion Failure")
    
    case requestFailed(message: String, code: Int64)
    case blockchainError(message: String, code: Int64)
    
    // MARK: - Registration errors
    case registration(message: String, currentState: String? = nil)
    
    // MARK: - socket errors
    case socketDisconnected
    
    case other(message: String) // ErrorAPI.responseUnsuccessful(message: "POST Request Failed")
    
    public var description: String {
        switch self {
        case .userNotFound:
            return ErrorMessage.userNotFound.rawValue
        case .unauthorized(message: let message):
            return "unauthorized".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "")
        case .secretVerificationFailed:
            return "Secret verification failed - access denied"
        case .noConnection:
            return "no internet connection".localized().uppercaseFirst
        case .invalidRequest(message: let message):
            return "request is invalid with error".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "")
        case .invalidResponse(message: let message, responseString: let responseString):
            return "response data is invalid with error".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "") + "\n" + (responseString != nil ? ": \(responseString!.localized().uppercaseFirst)" : "")
        case .requestFailed(message: let message, code: let code):
            return "request failed with error".localized().uppercaseFirst + ": " + "code".localized() + ": " + "\(code)" + ", " + "message".localized() + ": " + message
        case .blockchainError(message: let message, code: let code):
            return "blockchain operation error".localized().uppercaseFirst + ": " + "code".localized() + ": " + "\(code)" + ": " + "message".localized() + ": " + message
        case .registration(let message, _):
            return "registration error".localized().uppercaseFirst + ": " + message
        case .socketDisconnected:
            return "socket disconnected".localized().uppercaseFirst
        case .other(let errorMessage):
            return errorMessage
        }
    }
    
    public static var unknown: CMError {
        .other(message: "unknown")
    }
    
    public var message: String {
        switch self {
        case .userNotFound:
            return ErrorMessage.userNotFound.rawValue
        case .unauthorized(message: let message):
            return message ?? "unauthorized"
        case .secretVerificationFailed:
            return "Secret verification failed - access denied"
        case .noConnection:
            return ErrorMessage.noInternetConnection.rawValue
        case .invalidRequest(message: let message):
            return message ?? "request is invalid"
        case .invalidResponse(message: let message, responseString: _):
            return message ?? "response data is invalid"
        case .requestFailed(message: let message, code: _):
            return message
        case .blockchainError(message: let message, code: _):
            return message
        case .registration(let message, _):
            return message
        case .socketDisconnected:
            return "socket disconnected"
        case .other(let errorMessage):
            return errorMessage
        }
    }
}

extension CMError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return ErrorMessage.userNotFound.rawValue
        case .unauthorized(message: let message):
            return "unauthorized".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "")
        case .secretVerificationFailed:
            return "Secret verification failed - access denied"
        case .noConnection:
            return "no internet connection".localized().uppercaseFirst
        case .invalidRequest(message: let message):
            return "request is invalid with error".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "")
        case .invalidResponse(message: let message, responseString: let responseString):
            return "response data is invalid with error".localized().uppercaseFirst + (message != nil ? ": \(message!.localized().uppercaseFirst)" : "") + "\n" + (responseString != nil ? ": \(responseString!.localized().uppercaseFirst)" : "")
        case .requestFailed(message: let message, code: let code):
            return "request failed with error".localized().uppercaseFirst + ": " + "code".localized() + ": " + "\(code)" + ", " + "message".localized() + ": " + message
        case .blockchainError(message: let message, code: let code):
            return "blockchain operation error".localized().uppercaseFirst + ": " + "code".localized() + ": " + "\(code)" + ": " + "message".localized() + ": " + message
        case .registration(let message, _):
            return "registration error".localized().uppercaseFirst + ": " + message
        case .socketDisconnected:
            return "socket disconnected".localized().uppercaseFirst
        case .other(let errorMessage):
            return errorMessage
        }
    }
}

extension Error {
    public var cmError: CMError {
        if let error = self as? CMError {return error}
        return CMError.other(message: self.localizedDescription)
    }
}

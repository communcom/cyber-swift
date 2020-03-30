//
//  ResponseAPI.swift
//  CyberSwift
//
//  Created by msm72 on 13.04.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIResult<T: Decodable>: Decodable {
    public let id: UInt64
    public let jsonrpc: String
    public let result: T?
    public let error: ResponseAPIError?
}

public struct SocketResponse<T: Decodable>: Decodable {
    public let method: String
    public let jsonrpc: String
    public let params: T
}

/// [Multiple types](https://stackoverflow.com/questions/46759044/swift-structures-handling-multiple-types-for-a-single-property)
public struct Conflicted: Codable, Equatable {
    public let stringValue: String?
    
    // Where we determine what type the value is
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        do {
            stringValue = try container.decode(String.self)
        } catch {
            do {
                stringValue = "\(try container.decode(Int64.self))"
            } catch {
                stringValue = ""
            }
        }
    }
    
    // We need to go back to a dynamic type, so based on the data we have stored, encode to the proper type
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(stringValue)
    }
    
    public init(string: String?) {
        stringValue = string
    }
}

public enum StatusState: String {
    case ok         =   "OK"
    case error      =   "Error"
    case offline    =   "Offline"
}

// MARK: - Response Error
public struct ResponseAPIErrorResult: Decodable {
    // MARK: - In work
    public let error: ResponseAPIError
    public let id: Int64
    public let jsonrpc: String
}

public struct ResponseAPIError: Decodable {
    // MARK: - In work
    public let code: Int64
    public let message: String
    public let currentState: String?
    public let data: ResponseAPIErrorData?
}

public struct ResponseAPIErrorData: Decodable {
    public let code: Int64?
    public let message: String?
    public let error: ResponseAPIErrorError?
}

public struct ResponseAPIErrorError: Decodable {
    public let code: Int64
    public let name: String
    public let what: String
    public let details: [ResponseAPIErrorErrorDetail]?
}

public struct ResponseAPIErrorErrorDetail: Decodable {
    public let message: String
}

// MARK: - API `auth.authorize`
public struct ResponseAPIAuthAuthorize: Decodable {
    public let user: String
    public let username: String
    public let userId: String
    public let roles: [ResponseAPIAuthAuthorizeRole]?
    public let permission: String
}

public struct ResponseAPIAuthAuthorizeRole: Decodable {
    //    public let title: String?
}

public struct ResponseAPIAuthGenerateSecret: Decodable {
    public let secret: String
}

// MARK: - API `registration.getState`
public struct ResponseAPIRegistrationGetState: Decodable {
    public let currentState: String
    public let data: ResponseAPIRegistrationGetStateData?
}

public struct ResponseAPIRegistrationGetStateData: Decodable {
    public let userId: String?
    public let username: String?
}

// MARK: - API `registration.firstStep`
// {"jsonrpc":"2.0","id":1,"result":{"code":1234,"nextSmsRetry":"2019-10-30T09:51:27.649Z","currentState":"verify"}}
public struct ResponseAPIRegistrationFirstStep: Decodable {
    public let code: UInt64?
    public let currentState: String
    public let nextSmsRetry: String
}

public struct ResponseAPIRegistrationFirstStepEmail: Decodable {
    public let nextEmailRetry: String
    public let currentState: String
    public let code: String?
}

// MARK: - API `registration.verify`
// {"jsonrpc":"2.0","id":3,"result":{"currentState":"setUsername"}}
public struct ResponseAPIRegistrationVerify: Decodable {
    public let currentState: String
}

// MARK: - API `registration.setUsername`
// {"jsonrpc":"2.0","id":3,"result":{"userId":"tst5osiwjzpx","currentState":"toBlockChain"}}
public struct ResponseAPIRegistrationSetUsername: Decodable {
    public let userId: String?
    public let currentState: String
}

// MARK: - API `registration.resendSmsCode`
// {"jsonrpc":"2.0","id":3,"result":{"nextSmsRetry":"2019-10-30T10:05:08.338Z","currentState":"verify"}}
public struct ResponseAPIResendSmsCode: Decodable {
    public let nextSmsRetry: String
    public let currentState: String
}

public struct ResponseAPIResendEmailCode: Decodable {
    public let nextEmailRetry: String
    public let currentState: String
}

// MARK: - API `registration.toBlockChain`
// {"jsonrpc":"2.0","id":3,"result":{"userId":"tst5gtbbviic","currentState":"toBlockChain"}}
public struct ResponseAPIRegistrationToBlockChain: Decodable {
    public let userId: String
    public let currentState: String
}

// MARK: - API that returns status
public struct ResponseAPIStatus: Decodable {
    public let status: String
}

// MARK: - Generate new testnet accounts
public struct ResponseAPICreateNewAccount: Decodable {
    public let active_key: String
    public let alias: String
    public let comment_id: UInt16
    public let owner_key: String
    public let posting_key: String
    public let user_db_id: UInt64
    public let username: String
}

// MARK: - API `bandwidth.provide`
public struct ResponseAPIBandwidthProvide: Decodable {
    public let transaction_id: String
}

// MARK: - API `frame.getEmbed`
public struct ResponseAPIFrameGetEmbedResult: Decodable {
    public let jsonrpc: String
    public let id: UInt16
    public let result: ResponseAPIFrameGetEmbed?
    public let error: ResponseAPIError?
}

public struct ResponseAPIFrameGetEmbed: Codable {
    public var type: String?
    public let version: String?
    public let title: String?
    public var url: String?
    public let author: String?
    public let authorUrl: String?
    public let providerName: String?
    public let description: String?
    public let thumbnailUrl: String?
    public let thumbnailWidth: UInt?
    public let thumbnailHeight: UInt?
    public var html: String?
    public let contentLength: UInt32?
}

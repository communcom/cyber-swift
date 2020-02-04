//
//  RequestAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import Foundation

struct EncodableWrapper: Encodable {
    let wrapped: Encodable
    
    func encode(to encoder: Encoder) throws {
        try self.wrapped.encode(to: encoder)
    }
}

public struct RequestAPI: Encodable {
    public let id: Int
    public let method: String
    public let jsonrpc: String
    public let params: [String: Encodable]
    
    enum CodingKeys: String, CodingKey {
        case id
        case method
        case jsonrpc
        case params
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(method, forKey: .method)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        let wrappedDict = params.mapValues(EncodableWrapper.init(wrapped:))
        try container.encode(wrappedDict, forKey: .params)
    }
}

public enum VoteActionType: String {
    case unvote     =   "unvote"
    case upvote     =   "upvote"
    case downvote   =   "downvote"
}

public struct RequestAPIContentId: Encodable {
    public let userId: String
    public let permlink: String
    
    public init(responseAPI: ResponseAPIContentId) {
        self.userId = responseAPI.userId
        self.permlink = responseAPI.permlink
    }
}

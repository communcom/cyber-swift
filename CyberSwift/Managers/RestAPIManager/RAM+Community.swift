//
//  RAM+Community.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getCommunity(id: String, authorizationRequired: Bool = true) -> Single<ResponseAPIContentGetCommunity> {
        executeGetRequest(methodGroup: .content, methodName: "getCommunity", params: ["communityId": id], authorizationRequired: authorizationRequired)
    }
    
    public func getCommunity(alias: String, authorizationRequired: Bool = true) -> Single<ResponseAPIContentGetCommunity> {
        executeGetRequest(methodGroup: .content, methodName: "getCommunity", params: ["communityAlias": alias], authorizationRequired: authorizationRequired)
    }
    
    public func getCommunities(
        type: GetCommunitiesType?,
        userId: String? = Config.currentUser?.id,
        offset: Int?,
        limit: Int?,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetCommunities> {
        var params = [String: Encodable]()
        params["type"] = type?.rawValue
        if type == .user {
            params["userId"] = userId
        }
        params["offset"] = offset
        params["limit"] = limit
        params["allowedLanguages"] = ["all"]
        return executeGetRequest(methodGroup: .content, methodName: "getCommunities", params: params, authorizationRequired: authorizationRequired)
    }
    
    public func getLeaders(
        communityId: String?    = nil,
        communityAlias: String? = nil,
        sequenceKey: String?    = nil,
        limit: UInt8            = 10,
        query: String?          = nil,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetLeaders> {
        var params = [String: Encodable]()
        params["communityId"]       = communityId
        params["communityAlias"]    = communityAlias
        params["limit"]             = limit
        params["sequenceKey"]       = sequenceKey
        params["query"]             = query
        
        return executeGetRequest(methodGroup: .content, methodName: "getLeaders", params: params, authorizationRequired: authorizationRequired)
    }
    
    public func getCommunityBlacklist(communityId: String, limit: Int, offset: Int) -> Single<ResponseAPIContentGetSubscribers> {
        executeGetRequest(methodGroup: .content, methodName: "getCommunityBlacklist", params: ["communityId": communityId, "limit": limit, "offset": offset])
    }
}

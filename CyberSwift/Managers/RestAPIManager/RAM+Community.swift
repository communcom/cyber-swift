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
        
        let methodAPIType = MethodAPIType.getCommunity(id: id)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    public func getCommunity(alias: String, authorizationRequired: Bool = true) -> Single<ResponseAPIContentGetCommunity> {
        
        let methodAPIType = MethodAPIType.getCommunity(alias: alias)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    public func getCommunities(
        type: GetCommunitiesType?,
        userId: String? = Config.currentUser?.id,
        offset: Int?,
        limit: Int?,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetCommunities> {
        
        let methodAPIType = MethodAPIType.getCommunities(type: type, userId: userId, offset: offset, limit: limit)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    public func getLeaders(
        communityId: String?    = nil,
        communityAlias: String? = nil,
        sequenceKey: String?    = nil,
        limit: UInt8            = 10,
        query: String?          = nil,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentGetLeaders> {
        let methodAPIType = MethodAPIType.getLeaders(communityId: communityId, communityAlias: communityAlias, sequenceKey: sequenceKey, limit: Int(limit), query: query)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
}

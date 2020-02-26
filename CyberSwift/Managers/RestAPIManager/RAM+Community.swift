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
    public func getCommunity(id: String) -> Single<ResponseAPIContentGetCommunity> {
        
        let methodAPIType = MethodAPIType.getCommunity(id: id)
        
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getCommunity(alias: String) -> Single<ResponseAPIContentGetCommunity> {
        
        let methodAPIType = MethodAPIType.getCommunity(alias: alias)
        
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getCommunities(
        type: GetCommunitiesType?,
        userId: String? = Config.currentUser?.id,
        offset: Int?,
        limit: Int?,
        search: String? = nil
    ) -> Single<ResponseAPIContentGetCommunities> {
        
        let methodAPIType = MethodAPIType.getCommunities(type: type, userId: userId, search: search, offset: offset, limit: limit)
        
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getLeaders(
        communityId: String?    = nil,
        communityAlias: String? = nil,
        sequenceKey: String?    = nil,
        limit: UInt8            = 10,
        query: String?          = nil
    ) -> Single<ResponseAPIContentGetLeaders> {
        let methodAPIType = MethodAPIType.getLeaders(communityId: communityId, communityAlias: communityAlias, sequenceKey: sequenceKey, limit: Int(limit), query: query)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

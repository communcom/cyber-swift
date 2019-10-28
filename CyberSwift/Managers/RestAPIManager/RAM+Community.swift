//
//  RAM+Community.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getCommunity(id: String) -> Single<ResponseAPIContentGetCommunity> {
        
        let methodAPIType = MethodAPIType.getCommunity(id: id)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getCommunities(
        type: GetCommunitiesType,
        userId: String? = Config.currentUser?.id,
        offset: Int,
        limit: Int = 10
    ) -> Single<ResponseAPIContentGetCommunities> {
        
        let methodAPIType = MethodAPIType.getCommunities(type: type, userId: userId, offset: offset, limit: 10)
        
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getLeaders(
        communityId: String,
        sequenceKey: String?    = nil,
        limit: UInt8            = 10,
        query: String?          = nil
    ) -> Single<ResponseAPIContentGetLeaders> {
        let methodAPIType = MethodAPIType.getLeaders(communityId: communityId, sequenceKey: sequenceKey, limit: Int(limit), query: query)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

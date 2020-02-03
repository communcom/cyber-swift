//
//  RAM+Search.swift
//  CyberSwift
//
//  Created by Chung Tran on 2/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func quickSearch(
        queryString: String,
        entities: [String],
        limit: UInt
    ) -> Single<ResponseAPIContentEntitySearch> {
        let methodAPIType = MethodAPIType.quickSearch(queryString: queryString, entities: entities, limit: limit)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func extendedSearch(
        queryString: String,
        entities: [String: [String: UInt]]
    ) -> Single<ResponseAPIContentExtendedSearch> {
        let methodAPIType = MethodAPIType.extendedSearch(queryString: queryString, entities: entities)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func entitySearch(
        queryString: String,
        entity: String,
        limit: UInt,
        offset: UInt
    ) -> Single<ResponseAPIContentEntitySearch> {
        let methodAPIType = MethodAPIType.entitySearch(queryString: queryString, entity: entity, limit: limit, offset: offset)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

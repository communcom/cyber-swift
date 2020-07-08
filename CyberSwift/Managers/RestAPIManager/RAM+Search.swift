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
        entities: [SearchEntityType],
        limit: UInt,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentEntitySearch> {
        let methodAPIType = MethodAPIType.quickSearch(queryString: queryString, entities: entities, limit: limit)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    public func extendedSearch(
        queryString: String,
        entities: [SearchEntityType: [String: UInt]],
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentExtendedSearch> {
        let methodAPIType = MethodAPIType.extendedSearch(queryString: queryString, entities: entities)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    public func entitySearch(
        queryString: String,
        entity: SearchEntityType,
        limit: UInt,
        offset: UInt,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentEntitySearch> {
        let methodAPIType = MethodAPIType.entitySearch(queryString: queryString, entity: entity, limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
}

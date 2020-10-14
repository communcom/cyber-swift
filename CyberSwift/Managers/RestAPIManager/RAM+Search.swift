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
        executeGetRequest(methodGroup: .content, methodName: "quickSearch", params: ["queryString": queryString, "entities": entities, "limit": limit], authorizationRequired: authorizationRequired)
    }
    
    public func extendedSearch(
        queryString: String,
        entities: [SearchEntityType: [String: UInt]],
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentExtendedSearch> {
        var modifiedEntity = [String: [String: UInt]]()
        
        for (key, value) in entities {
            modifiedEntity[key.rawValue] = value
        }
        return executeGetRequest(methodGroup: .content, methodName: "extendedSearch", params: ["queryString": queryString, "entities": modifiedEntity], authorizationRequired: authorizationRequired)
    }
    
    public func entitySearch(
        queryString: String,
        entity: SearchEntityType,
        limit: UInt,
        offset: UInt,
        authorizationRequired: Bool = true
    ) -> Single<ResponseAPIContentEntitySearch> {
        executeGetRequest(methodGroup: .content, methodName: "entitySearch", params: ["queryString": queryString, "entity": entity, "limit": limit, "offset": offset])
    }
}

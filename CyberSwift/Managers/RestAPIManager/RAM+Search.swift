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
    ) -> Single<ResponseAPIContentQuickSearch> {
        let methodAPIType = MethodAPIType.quickSearch(queryString: queryString, entities: entities, limit: limit)
        return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
    }
}

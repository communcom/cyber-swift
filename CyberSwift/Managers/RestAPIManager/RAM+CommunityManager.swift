//
//  RAM+CommunityManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    public func getProposals(communityIds: [String], limit: Int, offset: Int) -> Single<ResponseAPIContentGetProposals> {
        let methodAPIType = MethodAPIType.getProposals(communityIds: communityIds, limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getReportsList(communityIds: [String], contentType: String, status: String, sortBy: SortBy, limit: Int, offset: Int) -> Single<ResponseAPIContentGetReportsList> {
        let methodAPIType = MethodAPIType.getReportsList(communityIds: communityIds, contentType: contentType, status: status, sortBy: sortBy, limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func getEntityReports(userId: String, communityId: String, permlink: String, limit: Int, offset: Int) -> Single<ResponseAPIContentGetEntityReports> {
        let methodAPIType = MethodAPIType.getEntityReports(userId: userId, communityId: communityId, permlink: permlink, limit: limit, offset: offset)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

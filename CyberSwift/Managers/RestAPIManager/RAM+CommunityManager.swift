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
    // MARK: - Create community
    public func getCreatedCommunities() -> Single<ResponseAPIGetUserCommunities> {
        executeGetRequest(methodGroup: .community, methodName: "getUsersCommunities", params: [:])
    }
    
    public func createNewCommunity(name: String) -> Single<ResponseAPICommunityCreateNewCommunity> {
        executeGetRequest(methodGroup: .community, methodName: "createNewCommunity", params: ["name": name])
    }
    
    public func commmunitySetSettings(name: String, description: String, language: String, communityId: String, avatarUrl: String = "", coverUrl: String = "", subject: String, rules: String) -> Single<ResponseAPIStatus> {
        executeGetRequest(methodGroup: .community, methodName: "setSettings", params: ["name": name, "avatarUrl": avatarUrl, "coverUrl": coverUrl, "language": language, "description": description, "rules": rules, "subject": subject, "communityId": communityId])
    }
    
    public func startCommunityCreation(communityId: String, transferTrxId: String?) -> Single<ResponseAPIStatus> {
        var parameters: [String: Encodable] = ["communityId": communityId]
        parameters["transferTrxId"] = transferTrxId
        return executeGetRequest(methodGroup: .community, methodName: "startCommunityCreation", params: parameters, timeout: 10000)
    }
    
    // MARK: - Manage community
    public func getProposals(communityIds: [String], limit: Int, offset: Int) -> Single<ResponseAPIContentGetProposals> {
        executeGetRequest(methodGroup: .content, methodName: "getProposals", params: ["communityIds": communityIds, "limit": limit, "offset": offset ])
    }
    
    public func getReportsList(communityIds: [String], contentType: String, status: String, sortBy: SortBy, limit: Int, offset: Int) -> Single<ResponseAPIContentGetReportsList> {
        executeGetRequest(methodGroup: .content, methodName: "getReportsList", params: ["communityIds": communityIds, "contentType": contentType, "status": status, "sortBy": sortBy.rawValue, "limit": limit, "offset": offset ])
    }
    
    public func getEntityReports(userId: String, communityId: String, permlink: String, limit: Int, offset: Int) -> Single<ResponseAPIContentGetEntityReports> {
        executeGetRequest(methodGroup: .content, methodName: "getEntityReports", params: ["userId": userId, "communityId": communityId, "permlink": permlink, "limit": limit, "offset": offset ])
    }
}

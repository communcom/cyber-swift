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
        let methodAPIType = MethodAPIType.getUsersCommunity
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func createNewCommunity(name: String) -> Single<ResponseAPICommunityCreateNewCommunity> {
        let methodAPIType = MethodAPIType.createNewCommunity(name: name)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func commmunitySetSettings(name: String, description: String, language: String, communityId: String, avatarUrl: String = "", coverUrl: String = "", subject: String = "", rules: String) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.communitySetSettings(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl, language: language, description: description, rules: rules, subject: subject, communityId: communityId)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func startCommunityCreation(communityId: String, transferTrxId: String?) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.startCommunityCreation(communityId: communityId, transferTrxId: transferTrxId)
        return executeGetRequest(methodAPIType: methodAPIType, timeout: 10000)
    }
    
    // MARK: - Manage community
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

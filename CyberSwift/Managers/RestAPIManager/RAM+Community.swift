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
    
    public func createNewCommunity(name: String) -> Single<ResponseAPICommunityCreateNewCommunity> {
        let methodAPIType = MethodAPIType.createNewCommunity(name: name)
        return executeGetRequest(methodAPIType: methodAPIType) as Single<ResponseAPICommunityCreateNewCommunity>
    }
    
    public func commmunitySetSettings(name: String, description: String, language: String, communityId: String, avatarUrl: String = "", coverUrl: String = "", subject: String = "") -> Single<ResponseAPIStatus> {
        let rules = "[{\"title\":\"Content:\",\"text\":\"- Here you can publish all types of content, create original or publish links to other sources;\\n- Content must be relevant to the thematic of the community;\",\"id\":\"x61mry8E\"},{\"title\":\"PROHIBITED:\",\"text\":\"- Publishing of NSFW content without tagging it as NSFW;\\n- Publishing of disturbing content, spam or advertisement is strictly forbidden;\\n- Insulting users in comments or posts;\\n- Publishing of personal data of people without their agreement;\",\"id\":\"KjJEGHLq\"},{\"title\":\"Rules violation:\",\"text\":\"In case of violation of the rules, comments and posts with violations will be deprived of payments and excluded from displaying in community and general feed. Also, leaders have the right to limit your access to the community\",\"id\":\"fGsrOj4o\"}]"
        let methodAPIType = MethodAPIType.communitySetSettings(name: name, avatarUrl: avatarUrl, coverUrl: coverUrl, language: language, description: description, rules: rules, subject: subject, communityId: communityId)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    public func startCommunityCreation(communityId: String, transferTrxId: String?) -> Single<ResponseAPIStatus> {
        let methodAPIType = MethodAPIType.startCommunityCreation(communityId: communityId, transferTrxId: transferTrxId)
        return executeGetRequest(methodAPIType: methodAPIType, timeout: 20)
    }
}

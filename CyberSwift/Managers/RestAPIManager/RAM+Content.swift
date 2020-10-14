//
//  RAM+Content.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/11/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension RestAPIManager {
    // MARK: - Posts
    // API `content.getPosts`
    public func getPosts(
        userId: String? = Config.currentUser?.id,
        communityId: String?,
        communityAlias: String? = nil,
        allowNsfw: Bool = false,
        type: FeedTypeMode,
        sortBy: SortBy? = nil,
        timeframe: FeedTimeFrameMode? = nil,
        limit: UInt = UInt(Config.paginationLimit),
        offset: UInt = 0,
        authorizationRequired: Bool = true,
        allowedLanguages: [String] = []
    ) -> Single<ResponseAPIContentGetPosts> {
        var parameters = [String: Encodable]()
        parameters["userId"]            = userId
        parameters["communityId"]       = communityId
        parameters["communityAlias"]    = communityAlias
        parameters["allowNsfw"]         = allowNsfw
        parameters["type"]              = type.rawValue
        if type != .new {
            parameters["sortBy"]        = sortBy?.rawValue
        }
        if type == .topLikes || type == .topComments || type == .topRewards || type == .subscriptionsPopular {
            parameters["timeframe"]     = timeframe?.rawValue
        }
        parameters["limit"]             = limit
        parameters["offset"]            = offset
        
        parameters["allowedLanguages"] = allowedLanguages
        
        return executeGetRequest(methodGroup: .content, methodName: "getPosts", params: parameters, authorizationRequired: authorizationRequired)
    }
    
    // API `content.getPost`
    public func loadPost(userId: String? = nil, username: String? = nil, permlink: String, communityId: String? = nil, communityAlias: String? = nil, authorizationRequired: Bool = true) -> Single<ResponseAPIContentGetPost> {
        
        var parameters = [String: Encodable]()
        parameters["userId"] = userId
        parameters["username"] = username
        parameters["permlink"] = permlink
        parameters["communityId"] = communityId
        parameters["communityAlias"] = communityAlias
        
        return executeGetRequest(methodGroup: .content, methodName: "getPost", params: parameters, authorizationRequired: authorizationRequired)
            .do(onSuccess: {$0.notifyChanged()})
    }
    
    // API `content.getComments` by post
    public func loadPostComments(
        sortBy: CommentSortMode         = .time,
        offset: UInt                    = 0,
        limit: UInt                     = UInt(Config.paginationLimit),
        userId: String?                 = Config.currentUser?.id,
        username: String?               = nil,
        permlink: String,
        communityId: String?            = nil,
        communityAlias: String?         = nil,
        parentCommentUserId: String?    = nil,
        parentCommentPermlink: String?  = nil,
        resolveNestedComments: Bool     = false,
        authorizationRequired: Bool     = true
    ) -> Single<ResponseAPIContentGetComments> {
        var parentComment: [String: String]?
        
        if let parentCommentUserId = parentCommentUserId,
            let parentCommentPermlink = parentCommentPermlink {
            parentComment = [
                "userId": parentCommentUserId,
                "permlink": parentCommentPermlink
            ]
        }
        
        var params: [String: Encodable] =
            [
                "type": "post",
                "sortBy": sortBy.rawValue,
                "offset": offset,
                "limit": limit,
                "userId": userId,
                "permlink": permlink,
                "parentComment": parentComment
            ]
        
        params["username"] = username
        
        if communityId == nil {
            params["communityAlias"] = communityAlias
        } else {
            params["communityId"] = communityId
        }
        
        params["resolveNestedComments"] = resolveNestedComments
        
        return executeGetRequest(methodGroup: .content, methodName: "getComments", params: params, authorizationRequired: authorizationRequired)
    }
    
    // API `meta.recordPostView`
    public func recordPostView(communityID: String, userID: String, permlink: String) -> Single<ResponseAPIStatus> {
        // Check user authorize
        guard Config.currentUser?.id != nil else { return .error(CMError.unauthorized()) }
        return executeGetRequest(methodGroup: .meta, methodName: "recordPostView", params: ["postLink": communityID + "/" + userID + "/" + permlink, "fingerPrint": Config.currentDeviceType])
    }
    
    // MARK: - Comments
    public func getRepliesForComment(
        forPost post: ResponseAPIContentId,
        parentComment: ResponseAPIContentId,
        offset: UInt                    = 0,
        limit: UInt                     = UInt(Config.paginationLimit),
        authorizationRequired: Bool     = true
    ) -> Single<ResponseAPIContentGetComments> {
        let params: [String: Encodable] =
            [
                "type": "post",
                "sortBy": CommentSortMode.timeDesc.rawValue,
                "offset": offset,
                "limit": limit,
                "userId": post.userId,
                "permlink": post.permlink,
                "parentComment": [
                    "userId": parentComment.userId,
                    "permlink": parentComment.permlink
                ],
                "communityId": post.communityId
            ]
        
        return executeGetRequest(methodGroup: .content, methodName: "getComments", params: params, authorizationRequired: authorizationRequired)
    }
    
    public func loadComment(userId: String, permlink: String, communityId: String) -> Single<ResponseAPIContentGetComment> {
        executeGetRequest(methodGroup: .content, methodName: "getComment", params: ["userId": userId, "permlink": permlink, "communityId": communityId])
    }
}

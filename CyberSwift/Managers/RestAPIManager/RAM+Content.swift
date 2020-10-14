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
        let methodAPIType = MethodAPIType.getPosts(userId: userId, communityId: communityId, communityAlias: communityAlias, allowNsfw: allowNsfw, type: type, sortBy: sortBy, timeframe: timeframe, limit: limit, offset: offset, allowedLanguages: allowedLanguages)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
    }
    
    // API `content.getPost`
    public func loadPost(userId: String? = nil, username: String? = nil, permlink: String, communityId: String? = nil, communityAlias: String? = nil, authorizationRequired: Bool = true) -> Single<ResponseAPIContentGetPost> {
        
        let methodAPIType = MethodAPIType.getPost(userId: userId, username: username, permlink: permlink, communityId: communityId, communityAlias: communityAlias)
        
        return executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: authorizationRequired)
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
                "username": username,
                "permlink": permlink,
                "parentComment": parentComment
            ]
        
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

        let methodAPIType = MethodAPIType.recordPostView(permlink: communityID + "/" + userID + "/" + permlink)

        return executeGetRequest(methodAPIType: methodAPIType)
    }
    
    // MARK: - Comments
    public func getRepliesForComment(
        forPost post: ResponseAPIContentId,
        parentComment: ResponseAPIContentId,
        offset: UInt                    = 0,
        limit: UInt                     = UInt(Config.paginationLimit),
        authorizationRequired: Bool     = true
    ) -> Single<ResponseAPIContentGetComments> {
        /*
         var parameters: [String: Encodable] =
             [
                 "type": type.rawValue,
                 "sortBy": sortBy?.rawValue,
                 "offset": offset,
                 "limit": limit
             ]
         
         switch type {
         case .user:
             parameters["userId"] = userId
         case .post:
             parameters["userId"] = userId
             parameters["username"] = username
             parameters["permlink"] = permlink
             parameters["parentComment"] = parentComment
         case .replies:
             parameters["userId"] = userId
             parameters["permlink"] = permlink
         }
         
         if communityId == nil {
             parameters["communityAlias"] = communityAlias
         } else {
             parameters["communityId"] = communityId
         }
         
         parameters["resolveNestedComments"] = resolveNestedComments
         
         return  (methodAPIType:     self,
                  methodGroup:       MethodAPIGroup.content.rawValue,
                  methodName:        "getComments",
                  parameters:        parameters)

         */
        
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
                ]
            ]
        
        return executeGetRequest(methodGroup: .content, methodName: "getComments", params: params, authorizationRequired: authorizationRequired)
    }
    
    public func loadComment(userId: String, permlink: String, communityId: String) -> Single<ResponseAPIContentGetComment> {
        let methodAPIType = MethodAPIType.getComment(userId: userId, permlink: permlink, communityId: communityId)
        return executeGetRequest(methodAPIType: methodAPIType)
    }
}

//
//  ResponseAPIContentGetPost.swift
//  Commun
//
//  Created by Chung Tran on 20/05/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift

extension ResponseAPIContentGetPost {
    public var content: [ResponseAPIContentBlock]? {
        return document?.content.arrayValue
    }
    
    public static var commentAddedEventName: String {"CommentAdded"}
    
    public mutating func notifyCommentAdded(_ comment: ResponseAPIContentGetComment) {
        let commentCount = (stats?.commentsCount ?? 0) + 1
        self.stats?.commentsCount = commentCount
        notifyEvent(eventName: Self.commentAddedEventName, object: comment)
        notifyChanged()
    }
    
    public var attachments: [ResponseAPIContentBlock] {
        let type = document?.attributes?.type
        if type == "basic" {
            return content?.first(where: {$0.type == "attachments"})?.content.arrayValue ?? []
        }
        
        if type == "article" {
            return content?.filter {$0.type == "image" || $0.type == "video" || $0.type == "website"} ?? []
        }
        
        return []
    }
    
    public var firstEmbedImageURL: String? {
        let type = document?.attributes?.type
        if type == "basic" {
            return content?.first(where: {$0.type == "attachments"})?.content.arrayValue?.first?.attributes?.thumbnailUrl
        }
        
        if type == "article" {
            return content?.first(where: {$0.type == "image" || $0.type == "video" || $0.type == "website"})?.attributes?.thumbnailUrl
        }
        
        return nil
    }
    
    public func markAsViewed() -> Disposable {
        RestAPIManager.instance.recordPostView(permlink: contentId.permlink)
            .subscribe(onSuccess: { (_) in
                var newPost = self
                newPost.viewsCount = (newPost.viewsCount ?? 0) + 1
                newPost.notifyChanged()
                RestAPIManager.instance.markedAsViewedPosts.insert(newPost.identity)
            })
    }
}

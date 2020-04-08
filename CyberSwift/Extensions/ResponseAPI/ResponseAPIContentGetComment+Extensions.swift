//
//  ResponseAPIContentGetComment.swift
//  Commun
//
//  Created by Chung Tran on 7/30/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIContentGetComment {
    init(
        contentId: ResponseAPIContentId,
        parents: ResponseAPIContentGetCommentParent,
        document: ResponseAPIContentBlock,
        author: ResponseAPIAuthor,
        community: ResponseAPIContentGetCommunity?,
        placeHolderImage: UIImage? = nil
    ) {
        let votes = ResponseAPIContentVotes(upCount: 0, downCount: 0)
        self.votes = votes

        let meta = ResponseAPIContentMeta(creationTime: Date().toString(), updateTime: nil, trxId: nil)
        self.meta = meta

        self.childCommentsCount = 0

        self.contentId = contentId

        self.parents = parents

        self.document = document

        self.author = author

        self.community = community
        
        self.children = []
        
        self.sendingState = MessageSendingState.none
        
        self.placeHolderImage = UIImageDumbDecodable(image: placeHolderImage)
    }
    
    public var content: [ResponseAPIContentBlock]? {
        return document?.content.arrayValue
    }
    
    public var firstEmbedImageURL: String? {
        return content?.first(where: {$0.type == "attachments"})?.content.arrayValue?.first?.attributes?.thumbnailUrl
    }
    
    public var attachments: [ResponseAPIContentBlock] {
        return content?.first(where: {$0.type == "attachments"})?.content.arrayValue ?? []
    }
    
    mutating public func addChildComment(_ comment: ResponseAPIContentGetComment) {
        children = (children ?? []) + [comment]
        childCommentsCount += 1
        notifyChanged()
        notifyChildrenChanged()
    }
    
    public static var childrenDidChangeEventName: String {"ChildrenDidChange"}
    
    public func notifyChildrenChanged() {
        notifyEvent(eventName: Self.childrenDidChangeEventName)
    }
}

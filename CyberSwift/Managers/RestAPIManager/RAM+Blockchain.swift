//
//  RestAPIManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 22/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension RestAPIManager: ReactiveCompatible {}

public typealias SendPostCompletion = (transactionId: String?, userId: String?, permlink: String?)

extension Reactive where Base: RestAPIManager {
    //  MARK: - Contract `gls.publish`
    public func vote(voteType:       VoteActionType,
                     author:         String,
                     permlink:       String,
                     weight:         Int16 = 0) -> Completable {
       
        
        return EOSManager.vote(voteType:    voteType,
                               author:      author,
                               permlink:    permlink,
                               weight:      voteType == .unvote ? 0 : 1)
    }

    public func create(
        commun_code:         String,
        message:             String,
        headline:            String? = nil,
        parentPermlink:      String? = nil,
        author:              String,
        tags:                [String]?
    ) -> Single<SendPostCompletion> {
        // Check for authorization
        guard let userId = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }

        // Prepare array
        let tags = tags ?? []
        
        // Construct message create Args
        
        let headermssgValue     =   headline ?? String(format: "Test Post Title %i", arc4random_uniform(100))
        let prefixTitle         =   parentPermlink == nil ? headermssgValue : "Comment"
        let messagePermlink     =   String.permlinkWith(string: prefixTitle)

        let message_id          =   EOSTransaction.Mssgid(authorValue: parentPermlink == nil ? author : userId, permlinkValue: messagePermlink)
        
        let parent_id           =   parentPermlink == nil ? EOSTransaction.Mssgid() : EOSTransaction.Mssgid(authorValue: author, permlinkValue: parentPermlink ?? messagePermlink)
        
        let messageCreateArgs   =   EOSTransaction.MessageCreateArgs(
            commun_code: commun_code,
            message_id: message_id,
            parent_id: parent_id,
            header: headermssgValue,
            body: message,
            tags: tags,
            metadata: "",
            curators_prcnt: 0,
            weight: nil)
        
        return EOSManager.create(messageCreateArgs: messageCreateArgs)
            .map {(transactionId: $0, userId: userId, permlink: messagePermlink)}
    }
    
    public func deleteMessage(permlink: String) -> Completable {
       
        
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let messageDeleteArgs = EOSTransaction.MessageDeleteArgs(authorValue: author, messagePermlink: permlink)
        return EOSManager.delete(messageArgs: messageDeleteArgs)
    }
    
    public func updateMessage(permlink:         String,
                              parentPermlink:   String?,
                              headline:         String,
                              message:          String,
                              tags:             [String]?,
                              metaData:         String
                              ) -> Single<SendPostCompletion> {
       
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.unauthorized)
        }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        let messageUpdateArgs = EOSTransaction.MessageUpdateArgs(
            authorValue:           author,
            messagePermlink:       permlink,
            parentPermlink:        parentPermlink,
            headermssgValue:       headline,
            bodymssgValue:         message,
            tagsValues:            arrayTags,
            jsonmetadataValue:     metaData)
        return EOSManager.update(messageArgs: messageUpdateArgs)
            .map {(transactionId: $0, userId: author, permlink: permlink)}
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       headermssg:          String,
                       bodymssg:            String) -> Single<String> {
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        return EOSManager.reblog(args: reblogArgs)
    }
    
    // MARK: - Contract `gls.social`
    public func update(userProfile: [String: String]) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let userProfileAccountmetaArgs = EOSTransaction.UserProfileAccountmetaArgs(json: userProfile)
        
        let userProfileMetaArgs = EOSTransaction.UserProfileUpdatemetaArgs(accountValue:    userID,
                                                                           metaValue:       userProfileAccountmetaArgs)
        
        return EOSManager.update(userProfileMetaArgs: userProfileMetaArgs)
    }
    
    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<String> {
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKeys?.privateKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let pinArgs = EOSTransaction.UserProfilePinArgs(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }
}

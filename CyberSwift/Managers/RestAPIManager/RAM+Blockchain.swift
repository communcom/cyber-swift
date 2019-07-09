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

extension Reactive where Base: RestAPIManager {
    //  MARK: - Contract `gls.publish`
    public func vote(voteType:       VoteActionType,
                     author:         String,
                     permlink:       String,
                     weight:         Int16 = 0) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        return EOSManager.vote(voteType:     voteType,
                                  author:       author,
                                  permlink:     permlink,
                                  weight:       voteType == .unvote ? 0 : 1)
    }
    
    public func create(message:             String,
                       headline:            String? = nil,
                       parentPermlink:      String? = nil,
                       tags:                [String]?,
                       metaData:            String) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let arrayTags = tags == nil ? [EOSTransaction.Tags()] : tags!.map({ EOSTransaction.Tags.init(tagValue: $0) })
        
        let messageCreateArgs = EOSTransaction.MessageCreateArgs(authorValue:        userID,
                                                                 parentPermlink:     parentPermlink,
                                                                 headermssgValue:    headline ?? String(format: "Test Post Title %i", arc4random_uniform(100)),
                                                                 bodymssgValue:      message,
                                                                 tagsValues:         arrayTags,
                                                                 jsonmetadataValue:  metaData)
        
        return EOSManager.create(messageCreateArgs: messageCreateArgs)
    }
    
    public func deleteMessage(permlink: String) -> Completable {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
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
                              ) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        guard let author = Config.currentUser?.id else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
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
    }
    
    public func reblog(author:              String,
                       rebloger:            String,
                       permlink:            String,
                       headermssg:          String,
                       bodymssg:            String) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        if (!Config.isNetworkAvailable) { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        let reblogArgs = EOSTransaction.ReblogArgs(authorValue:         author,
                                                   permlinkValue:       permlink,
                                                   reblogerValue:       rebloger,
                                                   headermssgValue:     headermssg,
                                                   bodymssgValue:       bodymssg)
        
        return EOSManager.reblog(args: reblogArgs)
    }
    
    // MARK: - Contract `gls.social`
    public func update(userProfile: [String: String]) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        guard Config.isNetworkAvailable else { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let userProfileAccountmetaArgs = EOSTransaction.UserProfileAccountmetaArgs(json: userProfile)
        
        let userProfileMetaArgs = EOSTransaction.UserProfileUpdatemetaArgs(accountValue:    userID,
                                                                           metaValue:       userProfileAccountmetaArgs)
        
        return EOSManager.update(userProfileMetaArgs: userProfileMetaArgs)
    }
    
    public func follow(_ userToFollow: String, isUnfollow: Bool = false) -> Single<ChainResponse<TransactionCommitted>> {
        // Offline mode
        guard Config.isNetworkAvailable else { return .error(ErrorAPI.disableInternetConnection(message: nil)) }
        
        // Check user authorize
        guard let userID = Config.currentUser?.id, let _ = Config.currentUser?.activeKey else {
            return .error(ErrorAPI.blockchain(message: "Unauthorized"))
        }
        
        let pinArgs = EOSTransaction.UserProfilePinArgs(pinnerValue: userID, pinningValue: userToFollow)
        return EOSManager.updateUserProfile(pinArgs: pinArgs, isUnpin: isUnfollow)
    }
}

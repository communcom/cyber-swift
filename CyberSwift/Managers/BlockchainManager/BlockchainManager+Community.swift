//
//  BlockchainManager+Community.swift
//  CyberSwift
//
//  Created by Chung Tran on 4/15/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import eosswift

extension BlockchainManager {
    // MARK: - Follow
    public func triggerFollow(community: ResponseAPIContentGetCommunity) -> Completable {
        // for reverse
        let originIsFollowing = community.isSubscribed ?? false
        let originIsInBlacklist = community.isInBlacklist ?? false
        
        // set value
        var community = community
        community.setIsSubscribed(!originIsFollowing)
        community.isInBlacklist = false
        community.isBeingJoined = true
        
        // notify changes
        community.notifyChanged()
        
        let request: Single<String>
        
        if originIsInBlacklist {
            request = unhideCommunity(community.communityId)
                .flatMap {_ in self.followCommunity(community.communityId)}
        } else if originIsFollowing {
            request = unfollowCommunity(community.communityId)
        } else {
            request = followCommunity(community.communityId)
        }
        
        return request
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .do(onError: { (_) in
                // reverse change
                community.setIsSubscribed(originIsFollowing)
                community.isBeingJoined = false
                community.isInBlacklist = originIsInBlacklist
                community.notifyChanged()
            }, onCompleted: {
                // re-enable state
                community.isBeingJoined = false
                community.notifyChanged()
                
                if community.isSubscribed == false {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.unfollowedEventName)
                } else {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.followedEventName)
                }
            })
    }
    
    // MARK: - Hide
    public func hideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.hideCommunity(args)
    }
    
    public func unhideCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unhideCommunity(args)
    }
    
    // MARK: - Leaders
    public func toggleVoteLeader(leader: ResponseAPIContentGetLeader) -> Completable {
        let originIsVoted = leader.isVoted ?? false
        
        // set value
        var leader = leader
        leader.setIsVoted(!originIsVoted)
        leader.isBeingVoted = true
        
        // notify change
        leader.notifyChanged()
        
        // send request
        let request: Single<String>
//        request = Single<String>.just("")
//            .delay(0.8, scheduler: MainScheduler.instance)
        if originIsVoted {
            // unvote
            request = BlockchainManager.instance.unvoteLeader(communityId: leader.communityId ?? "", leader: leader.userId)
        } else {
            request = BlockchainManager.instance.voteLeader(communityId: leader.communityId ?? "", leader: leader.userId)
        }
        
        return request
            .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
            .do(onError: { (_) in
                // reverse change
                // re-enable state
                leader.setIsVoted(originIsVoted)
                leader.isBeingVoted = false
                leader.notifyChanged()
            }, onCompleted: {
                // re-enable state
                leader.isBeingVoted = false
                leader.notifyChanged()
            })
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: - Helpers
    public func followCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let followArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.followCommunity(followArgs)
    }
    
    private func unfollowCommunity(_ communityId: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let unFollowArgs = EOSArgument.FollowUser(
            communCode: CyberSymbolWriterValue(name: communityId),
            follower: AccountNameWriterValue(name: userID)
        )

        return EOSManager.unfollowCommunity(unFollowArgs)
    }

    // MARK: - Managment
    public func approveProposal(_ proposalName: String, proposer: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.ProposalApprove(proposer: proposer,
                                               proposalName: proposalName,
                                               approver: userID)

        return EOSManager.approveProposal(args: args)
    }

    public func unapproveProposal(_ proposalName: String, proposer: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.ProposalApprove(proposer: proposer,
                                               proposalName: proposalName,
                                               approver: userID)

        return EOSManager.unapproveProposal(args: args)
    }

    public func execProposal(proposalName: String, proposer: String) -> Single<String> {
        // Check user authorize
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }

        let args = EOSArgument.ProposalApprove(proposer: proposer,
                                               proposalName: proposalName,
                                               approver: userID)

        return EOSManager.execProposal(args: args)
    }

    public func createBanProposal(proposalId proposalName: String? = nil, communityCode: String, commnityIssuer: String, permlink: String, author: String) -> Single<String> {
        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }
        
        let proposalName = proposalName ?? generateRandomProposalId()
        
        let data = EOSArgument.DeleteContent(communCode: CyberSymbolWriterValue(name: communityCode), messageID: EOSArgument.MessageIDContent(author: author, permlink: permlink))

        return prepareTransactionAbiForCommunityIssuer(commnityIssuer, permission: .lead(.minor), data: data, account: .gallery, contractName: "ban")
            .flatMap {
                let args = EOSArgument.Propose(communCode: communityCode, proposer: userID, proposalName: proposalName, permission: .lead(.minor), trx: $0)
                return EOSManager.propose(args: args)
            }
    }
    
    public func editCommunnity(_ proposalId: String? = nil, communityCode: String, commnityIssuer: String, description: String? = nil, language: String? = nil, rules: String? = nil, avatarImage: String? = nil, coverImage: String? = nil, subject: String? = nil) -> Single<String> {

        guard let userID = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }
        
        let proposalId = proposalId ?? generateRandomProposalId()
        
        let data = EOSArgument.SetInfo(communCode: communityCode, description: description, language: language, rules: rules, avatarImage: avatarImage, coverImage: coverImage, subject: subject)

        return prepareTransactionAbiForCommunityIssuer(commnityIssuer, data: data, account: .list, contractName: "setinfo")
            .flatMap {
                let args = EOSArgument.Propose(communCode: communityCode, proposer: userID, proposalName: proposalId, permission: .lead(.smajor), trx: $0)

                return EOSManager.propose(args: args)
            }
    }

    public func banUser(_ communityCode: String, commnityIssuer: String, proposalId: String? = nil, accountName: String, reason: String) -> Single<String> {
        guard let proposer = Config.currentUser?.id, Config.currentUser?.activeKeys?.privateKey != nil else {
            return .error(CMError.unauthorized())
        }
        let proposalId = proposalId ?? generateRandomProposalId()
        let data = EOSArgument.BanUser(communCode: communityCode,
                                       proposalName: proposalId,
                                       account: accountName,
                                       reason: reason)
        return prepareTransactionAbiForCommunityIssuer(commnityIssuer, data: data, account: .list, contractName: "ban")
            .flatMap {
                let args = EOSArgument.Propose(communCode: communityCode, proposer: proposer, proposalName: proposalId, permission: .lead(.smajor), trx: $0)

                return EOSManager.propose(args: args)
            }
    }

//    public func unbanUser(_ communityCode: String, proposer: String, accountName: String, reason: String) -> Single<String> {
//
//        let args = EOSArgument.UnbanUser(
//            communCode: communityCode,
//            proposer: proposer,
//            account: accountName,
////            reason: reason
//        )
//
//        return EOSManager.unbanUser(args: args)
//    }
    
    // MARK: - Helpers
    private func prepareTransactionAbiForCommunityIssuer(_ communityIssuer: String, permission: BCAccountPermission = .active, data: Encodable, account: BCAccountName, contractName: String) -> Single<TransactionAbi> {
        chainApi.getInfo().map { info in
            guard info.success else {
                throw CMError.blockchainError(message: ErrorMessage.couldNotRetrieveChainInfo.rawValue, code: 0)
            }

            let expiration = Date.defaultTransactionExpiry(expireSeconds: Config.expireProposalSeconds)

            let auth = TransactionAuthorizationAbi(
                    actor: AccountNameWriterValue(name: communityIssuer),
                    permission: AccountNameWriterValue(name: permission.rawValue))

            let action = ActionAbi(account: AccountNameWriterValue(name: account.stringValue),
                                    name: AccountNameWriterValue(name: contractName),
                                    authorization: [auth],
                                    data: DataWriterValue(hex: data.toHex()))

            let blockIdDetails = BlockIdDetails(blockId: info.body!.head_block_id)
            let abi = TransactionAbi(expiration: TimestampWriterValue(date: expiration),
                                     ref_block_num: BlockNumWriterValue(value: blockIdDetails.blockNum),
                                     ref_block_prefix: BlockPrefixWriterValue(value: blockIdDetails.blockPrefix),
                                     max_net_usage_words: 0,
                                     max_cpu_usage_ms: 0,
                                     max_ram_kbytes: 0,
                                     max_storage_kbytes: 0,
                                     delay_sec: 0,
                                     context_free_actions: [],
                                     actions: [action],
                                     transaction_extensions: StringCollectionWriterValue(value: []))
            return abi
        }
    }
    
    public func generateRandomProposalId() -> String {
        let prefix = "pri"
        return prefix + String.randomString(length: 12 - prefix.count, fromSet: String.latinLetters)
    }
}

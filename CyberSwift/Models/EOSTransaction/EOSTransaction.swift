//
//  EOSTransaction.swift
//  CyberSwift
//
//  Created by msm72 on 2/12/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
//  https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi
//

import RxSwift
import Foundation
import eosswift

public typealias Byte = UInt8
public typealias BaseT = Int64

protocol HasCommunCode {
    func getCode() -> CyberSymbolWriterValue
}

public class EOSTransaction {
    // MARK: - Properties
    private let _chainApi: ChainApi
    
    // MARK: - Initialization
    public init(chainApi: ChainApi) {
        self._chainApi = chainApi
    }
    
    public func chainApi() -> ChainApi {
        return _chainApi
    }
    
    // MARK: - Contract `gls.publish`
    /// Action `reblog`
    public struct ReblogArgs: Encodable {
        let rebloger: NameWriterValue
        let message_id: Mssgid
        let headermssg: String
        let bodymssg: String

        init(authorValue: String = "", permlinkValue: String = "", reblogerValue: String, headermssgValue: String, bodymssgValue: String) {
            self.rebloger   =   NameWriterValue(name: reblogerValue)
            self.message_id =   Mssgid(author: authorValue, permlink: permlinkValue)
            self.headermssg =   headermssgValue
            self.bodymssg   =   bodymssgValue
        }
    }
    
    /// Create Post/Comment
    public struct Mssgid: Encodable {
        let author: AccountNameWriterValue
        let permlink: String
        
        init(author: String = "", permlink: String = "") {
            self.author     =   AccountNameWriterValue(name: author)
            self.permlink   =   permlink
        }
    }
    
    /// Action `createmssg` (https://github.com/GolosChain/golos.contracts/blob/develop/golos.publication/golos.publication.abi#createmssg)
    public struct MessageCreateArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let message_id: Mssgid
        let parent_id: Mssgid?
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
        let metadata: String
        let weight: UInt64?

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    /// Update Post/Comment
    public struct MessageUpdateArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let message_id: Mssgid
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
        let metadata: String

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    /// Delete Post/Comment
    public struct MessageDeleteArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let message_id: Mssgid

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    /// Beneficiary
    public struct Beneficiary: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        let deductprcnt: BaseT
        
        // MARK: - Initialization
        init(accountValue: String = "", deductprcntValue: BaseT = 0) {
            self.account        =   NameWriterValue(name: accountValue)
            self.deductprcnt    =   deductprcntValue
        }
    }
    
    /// Tags
    public struct Tags: Encodable {
        // MARK: - Properties
        let tag: String
        
        // MARK: - Initialization
        init(tagValue: String = "test") {
            self.tag = tagValue
        }
    }
    
    /// Upvote
    public struct UpvoteArgs: Encodable, HasCommunCode {
        // MARK: - Properties
        let commun_code: CyberSymbolWriterValue
        let voter: AccountNameWriterValue
        let message_id: Mssgid
        let weight: Int
        
        // MARK: - Initialization
        init(communityID: String,
             voterValue: String,
             authorValue: String,
             permlinkValue: String) {
            self.commun_code =  CyberSymbolWriterValue(name: communityID)
            self.voter      =   AccountNameWriterValue(name: voterValue)
            self.message_id =   Mssgid(author: authorValue, permlink: permlinkValue)
            self.weight     =   Int(0)
        }

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    /// Unvote
    public struct UnvoteArgs: Encodable, HasCommunCode {
        // MARK: - Properties
        let commun_code: CyberSymbolWriterValue
        let voter: NameWriterValue
        let message_id: Mssgid
        
        // MARK: - Initialization
        init(communityID: String, voterValue: String, authorValue: String, permlinkValue: String) {
            self.commun_code =  CyberSymbolWriterValue(name: communityID)
            self.voter      =   NameWriterValue(name: voterValue)
            self.message_id =   Mssgid(author: authorValue, permlink: permlinkValue)
        }

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    /// Transfer
    public struct TransferArgs: Encodable {
        // MARK: - Properties
        let from: NameWriterValue
        let to: NameWriterValue
        let quantity: AssetWriterValue
        let memo: String
        
        // MARK: - Initialization
        init(fromValue: String, toValue: String, quantityValue: String, memoValue: String) {
            self.from       =   NameWriterValue(name: fromValue)
            self.to         =   NameWriterValue(name: toValue)
            self.quantity   =   AssetWriterValue(asset: quantityValue)
            self.memo       =   memoValue
        }
    }
    
    /// User profile: Pin/Unpin
    public struct UserProfilePinArgs: Encodable {
        // MARK: - Properties
        let pinner: NameWriterValue
        let pinning: NameWriterValue
        
        // MARK: - Initialization
        init(pinnerValue: String, pinningValue: String) {
            self.pinner     =   NameWriterValue(name: pinnerValue)
            self.pinning    =   NameWriterValue(name: pinningValue)
        }
    }
    
    /// User profile: Block/Unblock
    public struct UserProfileBlockArgs: Encodable {
        // MARK: - Properties
        let blocker: NameWriterValue
        let blocking: NameWriterValue
        
        // MARK: - Initialization
        init(blockerValue: String, blockingValue: String) {
            self.blocker    =   NameWriterValue(name: blockerValue)
            self.blocking   =   NameWriterValue(name: blockingValue)
        }
    }
    
    /// User profile: Changereput
    public struct UserProfileChangereputArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let author: NameWriterValue
        let rshares: Int64
        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, rsharesValue: Int64) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.author     =   NameWriterValue(name: authorValue)
            self.rshares    =   rsharesValue
        }
    }
    
    /// User profile: Updatemeta
    public struct UserProfileUpdatemetaArgs: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        let meta: UserProfileAccountmetaArgs
        
        // MARK: - Initialization
        init(accountValue: String, metaValue: UserProfileAccountmetaArgs) {
            self.account    =   NameWriterValue(name: accountValue)
            self.meta       =   metaValue
        }
    }
    
    /// User profile: Updatemeta
    public struct UserProfileAccountmetaArgs: Encodable {
        let avatar_url: String?
        let cover_url: String?
        let biography: String?
        let facebook: String?
        let telegram: String?
        let whatsapp: String?
        let wechat: String?
        
        // MARK: - Initialization
        init(json: [String: String?]) {
            self.avatar_url = json["avatar_url"] ?? nil
            self.cover_url = json["cover_url"] ?? nil
            self.biography = json["biography"] ?? nil
            self.facebook = json["facebook"] ?? nil
            self.telegram = json["telegram"] ?? nil
            self.whatsapp = json["whatsapp"] ?? nil
            self.wechat = json["wechat"] ?? nil
        }
    }
    
    /// User profile: Deletemeta
    public struct UserProfileDeleteArgs: Encodable {
        // MARK: - Properties
        let account: NameWriterValue
        
        // MARK: - Initialization
        init(accountValue: String) {
            self.account    =   NameWriterValue(name: accountValue)
        }
    }
    
    /// Block user
    public struct BlockUserArgs: Encodable {
        // MARK: - Properties
        let blocker: NameWriterValue
        let blocking: NameWriterValue
        
        init(blocker: String, blocking: String) {
            self.blocker = NameWriterValue(name: blocker)
            self.blocking = NameWriterValue(name: blocking)
        }
    }

    // MARK: - Contract `gls.ctrl`
    /// Action `regwitness` (1)
    public struct RegwitnessArgs: Encodable {
        let witness: NameWriterValue
        let url: String
        
        init(witnessValue: String, urlValue: String) {
            self.witness    =   NameWriterValue(name: witnessValue)
            self.url        =   urlValue
        }
    }
    
    /// Action `votewitness` (2)
    public struct VotewitnessArgs: Encodable {
        let voter: NameWriterValue
        let witness: NameWriterValue
        
        init(voterValue: String, witnessValue: String) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.witness    =   NameWriterValue(name: witnessValue)
        }
    }
    
    /// Action `unvotewitness` (3)
    public struct UnvotewitnessArgs: Encodable {
        let voter: NameWriterValue
        let witness: NameWriterValue
        
        init(voterValue: String, witnessValue: String) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.witness    =   NameWriterValue(name: witnessValue)
        }
    }
    
    /// Action `unregwitness` (4)
    public struct UnregwitnessArgs: Encodable {
        let witness: NameWriterValue
        
        init(witnessValue: String) {
            self.witness    =   NameWriterValue(name: witnessValue)
        }
    }
    
    /// Action `voteleader`
    public struct VoteLeaderArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let voter: NameWriterValue
        let leader: NameWriterValue
        let enable_pct: UInt8 //pct is optional, need 1 - there value
        let pct: UInt16?
        
        init(commun_code: String, voter: String, leader: String, pct: UInt16? = nil) {
            self.commun_code = CyberSymbolWriterValue(name: commun_code)
            self.voter = NameWriterValue(name: voter)
            self.leader = NameWriterValue(name: leader)
            self.pct = pct
            self.enable_pct = pct == nil ? 0 : 1
        }

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    /// Action `voteleader`
    public struct UnvoteLeaderArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let voter: NameWriterValue
        let leader: NameWriterValue
        
        init(commun_code: String, voter: String, leader: String, pct: UInt16? = nil) {
            self.commun_code = CyberSymbolWriterValue(name: commun_code)
            self.voter = NameWriterValue(name: voter)
            self.leader = NameWriterValue(name: leader)
        }

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }
    
    // MARK: - Contract `commun.list`
    /// Action `follow`
    public struct CommunListFollowArgs: Encodable, HasCommunCode {
        let commun_code: CyberSymbolWriterValue
        let follower: AccountNameWriterValue

        func getCode() -> CyberSymbolWriterValue {
            return commun_code
        }
    }

    public struct CommunBandwidthProvider: Encodable {
        let provider: AccountNameWriterValue
        let account: AccountNameWriterValue
    }

    /// Action `report`
    public struct ReprotArgs: Encodable, HasCommunCode {
        let communCode: CyberSymbolWriterValue
        let reporter: NameWriterValue
        let message: Mssgid
        let reason: String

        init(communityID: String,
             userID: String,
             autorID: String,
             permlink: String,
             reason: String) {
            self.communCode = CyberSymbolWriterValue(name: communityID)
            self.reporter = NameWriterValue(name: userID)
            self.message = Mssgid(author: autorID, permlink: permlink)
            self.reason = reason
        }

        func getCode() -> CyberSymbolWriterValue {
            return communCode
        }
    }

    public struct OpenBalanceArgs: Encodable {
        let owner: AccountNameWriterValue
        let commun_code: CyberSymbolWriterValue
        let enable_ram_player: UInt8 = 1 // ram_payer is optional, need 1 - there value
        let ram_payer: AccountNameWriterValue
    }
}

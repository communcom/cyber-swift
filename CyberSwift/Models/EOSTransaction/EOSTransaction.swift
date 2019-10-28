//
//  EOSTransaction.swift
//  CyberSwift
//
//  Created by msm72 on 2/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//
//  https://github.com/GolosChain/golos.contracts/blob/master/golos.publication/golos.publication.abi
//

import RxSwift
import eosswift
import Foundation

public typealias Byte = UInt8
public typealias BaseT = Int64

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
    
    
    //  MARK: - Contract `gls.publish`
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
        let author: NameWriterValue
        let permlink: String
        
        init(author: String = "", permlink: String = "") {
            self.author     =   NameWriterValue(name: author)
            self.permlink   =   permlink
        }
    }
    
    /// Action `createmssg` (https://github.com/GolosChain/golos.contracts/blob/develop/golos.publication/golos.publication.abi#createmssg)
    public struct MessageCreateArgs: Encodable {
        let commun_code: String
        let message_id: Mssgid
        let parent_id: Mssgid?
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
        let metadata: String
        let curators_prcnt: UInt64
        let weight: UInt64?
    }
    
    
    /// Update Post/Comment
    public struct MessageUpdateArgs: Encodable {
        let commun_code: String
        let message_id: Mssgid
        let parent_id: Mssgid?
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
    }
    
    
    /// Delete Post/Comment
    public struct MessageDeleteArgs: Encodable {
        // MARK: - Properties
        let message_id: Mssgid
        
        
        // MARK: - Initialization
        init(author: String = "CyberSwift", messagePermlink: String) {
            self.message_id = Mssgid(author: author, permlink: messagePermlink)
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
    public struct UpvoteArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let message_id: Mssgid
        let weight: BlockNumWriterValue
        
        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, permlinkValue: String, weightValue: Int16 = 0) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.message_id =   Mssgid(author: authorValue, permlink: permlinkValue)
            self.weight     =   BlockNumWriterValue(value: Int(weightValue))
        }
    }
    
    
    /// Unvote
    public struct UnvoteArgs: Encodable {
        // MARK: - Properties
        let voter: NameWriterValue
        let message_id: Mssgid
        
        
        // MARK: - Initialization
        init(voterValue: String, authorValue: String, permlinkValue: String) {
            self.voter      =   NameWriterValue(name: voterValue)
            self.message_id =   Mssgid(author: authorValue, permlink: permlinkValue)
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
        // MARK: - Properties
        let type: String?
        let app: String?
        let email: String?
        let phone: String?
        let facebook: String?
        let instagram: String?
        let telegram: String?
        let vk: String?
        let whatsapp: String?
        let wechat: String?
        let website: String?
        let first_name: String?
        let last_name: String?
        let name: String?
        let birth_date: String?
        let gender: String?
        let location: String?
        let city: String?
        let about: String?
        let occupation: String?
        let i_can: String?
        let looking_for: String?
        let business_category: String?
        let background_image: String?
        let cover_image: String?
        let profile_image: String?
        let user_image: String?
        let ico_address: String?
        let target_date: String?
        let target_plan: String?
        let target_point_a: String?
        let target_point_b: String?
        
        
        // MARK: - Initialization
        init(json: [String: String?]) {
            self.type               =   json["type"] ?? nil
            self.app                =   json["app"] ?? nil
            self.email              =   json["email"] ?? nil
            self.phone              =   json["phone"] ?? nil
            self.facebook           =   json["facebook"] ?? nil
            self.instagram          =   json["instagram"] ?? nil
            self.telegram           =   json["telegram"] ?? nil
            self.vk                 =   json["vk"] ?? nil
            self.whatsapp           =   json["whatsapp"] ?? nil
            self.wechat             =   json["wechat"] ?? nil
            self.website            =   json["website"] ?? nil
            self.first_name         =   json["first_name"] ?? nil
            self.last_name          =   json["last_name"] ?? nil
            self.name               =   json["name"] ?? nil
            self.birth_date         =   json["birth_date"] ?? nil
            self.gender             =   json["gender"] ?? nil
            self.location           =   json["location"] ?? nil
            self.city               =   json["city"] ?? nil
            self.about              =   json["about"] ?? nil
            self.occupation         =   json["occupation"] ?? nil
            self.i_can              =   json["i_can"] ?? nil
            self.looking_for        =   json["looking_for"] ?? nil
            self.business_category  =   json["business_category"] ?? nil
            self.background_image   =   json["background_image"] ?? nil
            self.cover_image        =   json["cover_image"] ?? nil
            self.profile_image      =   json["profile_image"] ?? nil
            self.user_image         =   json["user_image"] ?? nil
            self.ico_address        =   json["ico_address"] ?? nil
            self.target_date        =   json["target_date"] ?? nil
            self.target_plan        =   json["target_plan"] ?? nil
            self.target_point_a     =   json["target_point_a"] ?? nil
            self.target_point_b     =   json["target_point_b"] ?? nil
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
    

    //  MARK: - Contract `gls.ctrl`
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
    
    // MARK: - Contract `commun.list`
    /// Action `follow`
    public struct CommunListFollowArgs: Encodable {
        let commun_code: String
        let follower: String
    }
    
    /// Action `unfollow`
    public struct CommunListUnfollowArgs: Encodable {
        let commun_code: String
        let follower: String
    }
}

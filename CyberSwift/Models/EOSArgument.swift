//
//  EOSArgument.swift
//  CyberSwift
//
//  Created by Artem Shilin on 18.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import eosswift

protocol EOSArgumentCodeProtocol {
    var communCode: CyberSymbolWriterValue { get }
    func getCode() -> CyberSymbolWriterValue
}

extension EOSArgumentCodeProtocol {
    func getCode() -> CyberSymbolWriterValue {
        communCode
    }
}

struct EOSArgument {
    // MARK: - Content
    struct CreateContent: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let message_id: MessageIDContent
        let parentID: MessageIDContent?
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
        let metadata: String
        let weight: UInt64?
    }

    struct UpdateContent: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let messageID: MessageIDContent
        let header: String
        let body: String
        let tags: StringCollectionWriterValue
        let metadata: String
    }

    struct DeleteContent: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let messageID: MessageIDContent
    }

    struct VoteContent: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let voter: AccountNameWriterValue
        let messageID: MessageIDContent
        let weight: Int

        init(communityID: String, voterValue: String, authorValue: String, permlinkValue: String) {
            self.communCode = CyberSymbolWriterValue(name: communityID)
            self.voter = AccountNameWriterValue(name: voterValue)
            self.messageID = MessageIDContent(author: authorValue, permlink: permlinkValue)
            self.weight = Int(0) //always nil, 0 - empty optional value
        }
    }

    struct ReportContent: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let reporter: NameWriterValue
        let message: MessageIDContent
        let reason: String

        init(communityID: String, userID: String, authorID: String, permlink: String, reason: String) {
            self.communCode = CyberSymbolWriterValue(name: communityID)
            self.reporter = NameWriterValue(name: userID)
            self.message = MessageIDContent(author: authorID, permlink: permlink)
            self.reason = reason
        }
    }

    struct MessageIDContent: Encodable {
        let author: AccountNameWriterValue
        let permlink: String

        init(author: String = "", permlink: String = "") {
            self.author = AccountNameWriterValue(name: author)
            self.permlink = permlink
        }
    }

    // MARK: - Wallet
    struct Transfer: Encodable {
        let from: NameWriterValue
        let to: NameWriterValue
        let quantity: AssetWriterValue
        let memo: String

        init(fromValue: String, toValue: String, quantityValue: String, memoValue: String) {
            self.from = NameWriterValue(name: fromValue)
            self.to = NameWriterValue(name: toValue)
            self.quantity = AssetWriterValue(asset: quantityValue)
            self.memo = memoValue
        }
    }

    // MARK: - User
    struct PinUser: Encodable {
        let pinner: NameWriterValue
        let pinning: NameWriterValue

        init(pinnerValue: String, pinningValue: String) {
            self.pinner = NameWriterValue(name: pinnerValue)
            self.pinning = NameWriterValue(name: pinningValue)
        }
    }

    struct BlockUser: Encodable {
        let blocker: NameWriterValue
        let blocking: NameWriterValue

        init(blocker: String, blocking: String) {
            self.blocker = NameWriterValue(name: blocker)
            self.blocking = NameWriterValue(name: blocking)
        }
    }

    struct UpdateUser: Encodable {
        let account: NameWriterValue
        let meta: UserProfileAccountmetaArgs

        init(accountValue: String, metaValue: UserProfileAccountmetaArgs) {
            self.account = NameWriterValue(name: accountValue)
            self.meta = metaValue
        }
    }

    struct UserProfileAccountmetaArgs: Encodable {
        let avatar_url: String?
        let cover_url: String?
        let biography: String?
        let facebook: String?
        let telegram: String?
        let whatsapp: String?
        let wechat: String?
        let first_name: String?
        let last_name: String?
        let country: String?
        let city: String?
        let birth_date_disable: UInt8 = 0
        let birth_date: UInt64? // change to string after update contract
        let instagram: String?
        let linkedin: String?
        let twitter: String?
        let github: String?
        let website_url: String?

        // MARK: - Initialization
        init(json: [String: String?]) {
            self.avatar_url = json["avatar_url"] ?? nil
            self.cover_url = json["cover_url"] ?? nil
            self.biography = json["biography"] ?? nil
            self.facebook = json["facebook"] ?? nil
            self.telegram = json["telegram"] ?? nil
            self.whatsapp = json["whatsapp"] ?? nil
            self.wechat = json["wechat"] ?? nil
            self.first_name = json["first_name"] ?? nil
            self.last_name = json["last_name"] ?? nil
            self.country = json["country"] ?? nil
            self.city = json["city"] ?? nil
            self.birth_date = nil //json["birth_date"] ?? nil
            self.instagram = json["instagram"] ?? nil
            self.linkedin = json["linkedin"] ?? nil
            self.twitter = json["twitter"] ?? nil
            self.github = json["github"] ?? nil
            self.website_url = json["website_url"] ?? nil
        }
    }

    struct DeleteUser: Encodable {
        let account: NameWriterValue

        init(accountValue: String) {
            self.account = NameWriterValue(name: accountValue)
        }
    }

    struct FollowUser: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let follower: AccountNameWriterValue
    }

    // MARK: - Community
    struct VoteLeader: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let voter: NameWriterValue
        let leader: NameWriterValue
        let enablePct: UInt8 //pct is optional, need 1 - there value
        let pct: UInt16?

        init(communCode: String, voter: String, leader: String, pct: UInt16? = nil) {
            self.communCode = CyberSymbolWriterValue(name: communCode)
            self.voter = NameWriterValue(name: voter)
            self.leader = NameWriterValue(name: leader)
            self.pct = pct
            self.enablePct = pct == nil ? 0 : 1
        }
    }

    struct UnvoteLeader: Encodable, EOSArgumentCodeProtocol {
        let communCode: CyberSymbolWriterValue
        let voter: NameWriterValue
        let leader: NameWriterValue

        init(communCode: String, voter: String, leader: String, pct: UInt16? = nil) {
            self.communCode = CyberSymbolWriterValue(name: communCode)
            self.voter = NameWriterValue(name: voter)
            self.leader = NameWriterValue(name: leader)
        }
    }

    struct OpenBalance: Encodable {
        let owner: NameWriterValue
        let communCode: CyberSymbolWriterValue
        let enableRamPayer: UInt8 = 1 // ram_payer is optional, need 1 - there value
        let ramPayer: NameWriterValue
    }

    struct OpenCommunBalance: Encodable, EOSArgumentCodeProtocol {
        let owner: NameWriterValue
        let communCode: CyberSymbolWriterValue
        let ramPayer: NameWriterValue

        init(owner: String, communCode: String, ramPayer: String) {
            self.communCode = CyberSymbolWriterValue(name: communCode)
            self.owner = NameWriterValue(name: owner)
            self.ramPayer = NameWriterValue(name: ramPayer)
        }
    }
}

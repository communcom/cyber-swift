//
//  ResponseAPI+CommiunityManager.swift
//  CyberSwift
//
//  Created by Chung Tran on 8/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIContentGetProposals: Decodable {
    public let items: [ResponseAPIContentGetProposal]
    public let proposalsCount: UInt64
}

public struct ResponseAPIContentGetProposal: ListItemType {
    public let proposer: ResponseAPIContentGetProfile?
    public let proposalId: String
    public let type: String?
    public let contract: String?
    public let action: String?
    public let permission: String?
    public let blockTime: String?
    public let expiration: String?
    public let data: ResponseAPIContentGetProposalData?
    public let contentType: String?
    public let community: ResponseAPIContentGetCommunity?
    public let isApproved: Bool?
    public let approvesCount: UInt64?
    public let approvesNeed: UInt64?
    public let change: ResponseAPIContentGetProposalChange?
    
    public var identity: String {
        proposalId
    }
    
    public func newUpdatedItem(from item: ResponseAPIContentGetProposal) -> ResponseAPIContentGetProposal? {
        ResponseAPIContentGetProposal(
            proposer: item.proposer ?? proposer,
            proposalId: item.proposalId,
            type: item.type ?? type,
            contract: item.contract ?? contract,
            action: item.action ?? action,
            permission: item.permission ?? permission,
            blockTime: item.blockTime ?? blockTime,
            expiration: item.expiration ?? expiration,
            data: item.data ?? data,
            contentType: item.contentType ?? contentType,
            community: item.community ?? community,
            isApproved: item.isApproved ?? isApproved,
            approvesCount: item.approvesCount ?? approvesCount,
            approvesNeed: item.approvesNeed ?? approvesNeed,
            change: item.change ?? change
        )
    }
}

public struct ResponseAPIContentGetProposalData: Decodable, Equatable {
    public let commun_code: String?
    public let message_id: ResponseAPIContentGetProposalDataMessageId?
    public let description: String?
    public let language: String?
    public let rules: String?
    public let avatar_image: String?
    public let cover_image: String?
    public let subject: String?
}

public struct ResponseAPIContentGetProposalDataMessageId: Decodable, Equatable {
    public let author: String?
    public let permlink: String?
}

public struct ResponseAPIContentGetProposalChange: Decodable, Equatable {
    public let type: String?
    public let old: String?
    public let new: String?
}

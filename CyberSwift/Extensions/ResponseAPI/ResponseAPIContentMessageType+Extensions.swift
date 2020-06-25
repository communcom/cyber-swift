//
//  ResponseAPIContentMessageType+Extensions.swift
//  CyberSwift
//
//  Created by Chung Tran on 6/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ResponseAPIContentMessageType {
    public func upVote() -> Completable {
        if contentId.userId == Config.currentUser?.id {
            return .error(CMError.invalidRequest(message: "can't cancel vote on own publication"))
        }
        
        var modifiedMessage = self
        if modifiedMessage.votes.hasUpVote != true {
            // show donationButtons
            modifiedMessage.showDonationButtons = true
            modifiedMessage.notifyChanged()
        }
        
        return BlockchainManager.instance.upvoteMessage(modifiedMessage)
    }
    
    public func downVote() -> Completable {
        if contentId.userId == Config.currentUser?.id {
            return .error(CMError.invalidRequest(message: "can't cancel vote on own publication"))
        }
        
        return BlockchainManager.instance.downvoteMessage(self)
    }
}

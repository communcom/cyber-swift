//
//  ResponseAPIGetOptionsNotifyShow+Extensions.swift
//  CyberSwift
//
//  Created by Chung Tran on 19/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIGetOptionsNotifyShow {
    public func toParam() -> RequestParameterAPI.NoticeOptions {
        #warning("types unsubscribe, witnessVote, witnessCancelVote missing")
        return RequestParameterAPI.NoticeOptions(
            upvote: upvote,
            downvote: downvote,
            transfer: transfer,
            reply: reply,
            subscribe: subscribe,
            unsubscribe: false,
            mention: mention,
            repost: repost,
            reward: reward,
            curatorReward: curatorReward,
            witnessVote: false,
            witnessCancelVote: false
        )
    }
    
}

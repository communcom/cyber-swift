//
//  MethodAPI.swift
//  CyberSwift
//
//  Created by msm72 on 12.04.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//
//  This enum use for GET Requests
//
//  API DOC:                https://github.com/GolosChain/api-documentation
//  FACADE-SERVICE:         https://github.com/GolosChain/facade-service/tree/develop
//  REGISTRATION-SERVICE:   https://github.com/GolosChain/registration-service/tree/develop
//

import Foundation
import Localize_Swift

/// Type of request parameters

public enum MethodAPIGroup: String {
    case offline            =   "offline"
    case options            =   "options"
    case onlineNotify       =   "onlineNotify"
    case notifications      =   "notifications"
    case push               =   "push"
    case notify             =   "notify"
    case meta               =   "meta"
    case frame              =   "frame"
    case registration       =   "registration"
    case rates              =   "rates"
    case content            =   "content"
    case auth               =   "auth"
    case bandwidth          =   "bandwidth"
    case config             =   "config"
    case wallet             =   "wallet"
    case exchange           =   "exchange"
    case device             =   "device"
    case settings           =   "settings"
    case rewards            =   "rewards"
    case airdrop            =   "airdrop"
    case community          =   "community"
}

public enum FeedTypeMode: String, Codable {
    case new                    =   "new"
    case community              =   "community"
    case subscriptions          =   "subscriptions"
    case byUser                 =   "byUser"
    case topLikes               =   "topLikes"
    case topComments            =   "topComments"
    case topRewards             =   "topRewards"
    case hot                    =   "hot"
    case voted                  =   "voted"
    case subscriptionsHot       =   "subscriptionsHot"
    case subscriptionsPopular   =   "subscriptionsPopular"
    
    public var localizedLabel: String? {
        switch self {
        case .hot, .subscriptionsHot:
            return "hot".localized()
        case .new:
            return "new".localized()
        case .topLikes, .subscriptionsPopular:
            return "popular".localized()
        default:
            return nil
        }
    }
}

public enum FeedTimeFrameMode: String, Codable {
    case day                =   "day"
    case week               =   "week"
    case month              =   "month"
//    case year               =   "year"
    case all                =   "all"
//    case wilsonHot          =   "WilsonHot"
//    case wilsonTrending     =   "WilsonTrending"
    
    public var localizedLabel: String {
        switch self {
        case .day:
            return "past 24 hours".localized()
        case .week:
            return "past week".localized()
        case .month:
            return "past month".localized()
        case .all:
            return "all time".localized()
        }
    }
}

public enum SortBy: String, Codable {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
}

public enum CommentTypeMode: String {
    case user               =   "user"
    case post               =   "post"
}

public enum CommentSortMode: String {
    case time               =   "time"
    case timeDesc           =   "timeDesc"
    case popularity         =   "popularity"
}

public enum GetCommentsType: String {
    case user               =   "user"
    case post               =   "post"
    case replies            =   "replies"
}

public enum RegistrationStategyMode: String {
    case smsFromUser        =   "smsFromUser"
    case smsToUser          =   "smsToUser"
    case mail               =   "mail"
    case social             =   "social"
}

public enum AppProfileType: String {
    case golos              =   "gls"
    case cyber              =   "cyber"
}

public enum GetCommunitiesType: String {
    case all                =   "all"
    case user               =   "user"
}

public enum GetSubscriptionsType: String {
    case user               =   "user"
    case community          =   "community"
}

public enum GetBlacklistType: String {
    case users              =   "users"
    case communities        =   "communities"
}

public enum SearchEntityType: String, Encodable {
    case posts
    case communities
    case profiles
}

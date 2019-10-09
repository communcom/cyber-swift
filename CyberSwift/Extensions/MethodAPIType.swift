//
//  MethodAPI.swift
//  CyberSwift
//
//  Created by Chung Tran on 04/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension MethodAPIType {
    func decode(from jsonData: Data) throws -> ResponseAPIType {
        switch self {
        // FACADE-SERVICE
        case .getFeed(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetFeedResult.self, from: jsonData), errorAPI: nil)
            
        case .getPost(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetPostResult.self, from: jsonData), errorAPI: nil)
            
        case .waitForTransaction(id: _):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentWaitForTransactionResult.self, from: jsonData), errorAPI: nil)
            
        case .getUserComments(_), .getPostComments(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetCommentsResult.self, from: jsonData), errorAPI: nil)
            
        case .getProfile(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetProfileResult.self, from: jsonData), errorAPI: nil)
            
        case .authorize(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIAuthAuthorizeResult.self, from: jsonData), errorAPI: nil)
            
        case .logout:
            return (responseAPI: nil, errorAPI: nil)
            
        case .generateSecret:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIAuthGenerateSecretResult.self, from: jsonData), errorAPI: nil)
            
        case .getPushHistoryFresh:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIPushHistoryFreshResult.self, from: jsonData), errorAPI: nil)
            
        case .notifyPushOn(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPINotifyPushOnResult.self, from: jsonData), errorAPI: nil)
            
        case .notifyPushOff(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPINotifyPushOffResult.self, from: jsonData), errorAPI: nil)
            
        case .getOnlineNotifyHistory(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIOnlineNotifyHistoryResult.self, from: jsonData), errorAPI: nil)
            
        case .getOnlineNotifyHistoryFresh:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIOnlineNotifyHistoryFreshResult.self, from: jsonData), errorAPI: nil)
            
        case .notifyMarkAllAsViewed:
            return (responseAPI: try JSONDecoder().decode(ResponseAPINotifyMarkAllAsViewedResult.self, from: jsonData), errorAPI: nil)
            
        case .getOptions:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIGetOptionsResult.self, from: jsonData), errorAPI: nil)
            
        case .setBasicOptions(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPISetOptionsBasicResult.self, from: jsonData), errorAPI: nil)
            
        case .setNotice(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPISetOptionsNoticeResult.self, from: jsonData), errorAPI: nil)
            
        case .markAsRead(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIMarkNotifiesAsReadResult.self, from: jsonData), errorAPI: nil)
            
        case .recordPostView(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIMetaRecordPostViewResult.self, from: jsonData), errorAPI: nil)
            
        case .getFavorites:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIGetFavoritesResult.self, from: jsonData), errorAPI: nil)
            
        case .addFavorites(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIAddFavoritesResult.self, from: jsonData), errorAPI: nil)
            
        case .removeFavorites(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRemoveFavoritesResult.self, from: jsonData), errorAPI: nil)
            
        case .getCommunity(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetCommunityResult.self, from: jsonData), errorAPI: nil)
            
        case .getCommunitiesList(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIContentGetCommunitiesListResult.self, from: jsonData), errorAPI: nil)
            
            
        // REGISTRATION-SERVICE
        case .getState(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRegistrationGetStateResult.self, from: jsonData), errorAPI: nil)
            
        case .firstStep(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRegistrationFirstStepResult.self, from: jsonData), errorAPI: nil)
            
        case .resendSmsCode(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResendSmsCodeResult.self, from: jsonData), errorAPI: nil)
            
        case .verify(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRegistrationVerifyResult.self, from: jsonData), errorAPI: nil)
            
        case .setUser(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRegistrationSetUsernameResult.self, from: jsonData), errorAPI: nil)
            
        case .toBlockChain(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIRegistrationToBlockChainResult.self, from: jsonData), errorAPI: nil)
        
        /// CHAIN-SERVICE
        case .bandwidthProvide(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIBandwidthProvideResult.self, from: jsonData), errorAPI: nil)
            
        /// OTHER
        case .getEmbed(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIFrameGetEmbedResult.self, from: jsonData), errorAPI: nil)
        }
    }
}

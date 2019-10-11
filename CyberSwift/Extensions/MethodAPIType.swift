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
        case .getPosts(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetPosts>.self, from: jsonData), errorAPI: nil)
            
        case .getPost(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetPost>.self, from: jsonData), errorAPI: nil)
            
        case .waitForTransaction(id: _):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentWaitForTransaction>.self, from: jsonData), errorAPI: nil)
            
        case .getComments(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetComments>.self, from: jsonData), errorAPI: nil)
            
        case .getProfile(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetProfile>.self, from: jsonData), errorAPI: nil)
            
        case .authorize(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIAuthAuthorize>.self, from: jsonData), errorAPI: nil)
            
        case .logout:
            return (responseAPI: nil, errorAPI: nil)
            
        case .generateSecret:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIAuthGenerateSecret>.self, from: jsonData), errorAPI: nil)
            
        case .getPushHistoryFresh:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIPushHistoryFresh>.self, from: jsonData), errorAPI: nil)
            
        case .notifyPushOn(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPINotifyPushOn>.self, from: jsonData), errorAPI: nil)
            
        case .notifyPushOff(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPINotifyPushOff>.self, from: jsonData), errorAPI: nil)
            
        case .getOnlineNotifyHistory(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIOnlineNotifyHistory>.self, from: jsonData), errorAPI: nil)
            
        case .getOnlineNotifyHistoryFresh:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIOnlineNotifyHistoryFresh>.self, from: jsonData), errorAPI: nil)
            
        case .notifyMarkAllAsViewed:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPINotifyMarkAllAsViewed>.self, from: jsonData), errorAPI: nil)
            
        case .getOptions:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIGetOptions>.self, from: jsonData), errorAPI: nil)
            
        case .setBasicOptions(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPISetOptionsBasic>.self, from: jsonData), errorAPI: nil)
            
        case .setNotice(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPISetOptionsNotice>.self, from: jsonData), errorAPI: nil)
            
        case .markAsRead(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIMarkNotifiesAsRead>.self, from: jsonData), errorAPI: nil)
            
        case .recordPostView(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIMetaRecordPostView>.self, from: jsonData), errorAPI: nil)
            
        case .getFavorites:
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIGetFavorites>.self, from: jsonData), errorAPI: nil)
            
        case .addFavorites(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIAddFavorites>.self, from: jsonData), errorAPI: nil)
            
        case .removeFavorites(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRemoveFavorites>.self, from: jsonData), errorAPI: nil)
            
        case .getCommunity(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetCommunity>.self, from: jsonData), errorAPI: nil)
            
        case .getCommunities(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIContentGetCommunities>.self, from: jsonData), errorAPI: nil)
            
            
        // REGISTRATION-SERVICE
        case .getState(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRegistrationGetState>.self, from: jsonData), errorAPI: nil)
            
        case .firstStep(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRegistrationFirstStep>.self, from: jsonData), errorAPI: nil)
            
        case .resendSmsCode(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIResendSmsCode>.self, from: jsonData), errorAPI: nil)
            
        case .verify(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRegistrationVerify>.self, from: jsonData), errorAPI: nil)
            
        case .setUser(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRegistrationSetUsername>.self, from: jsonData), errorAPI: nil)
            
        case .toBlockChain(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIRegistrationToBlockChain>.self, from: jsonData), errorAPI: nil)
        
        /// CHAIN-SERVICE
        case .bandwidthProvide(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIBandwidthProvide>.self, from: jsonData), errorAPI: nil)
            
        /// OTHER
        case .getEmbed(_):
            return (responseAPI: try JSONDecoder().decode(ResponseAPIResult<ResponseAPIFrameGetEmbed>.self, from: jsonData), errorAPI: nil)
        }
    }
}

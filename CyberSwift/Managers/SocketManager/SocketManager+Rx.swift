//
//  SocketManager+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 23/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import Starscream
import RxSwift
import SwiftyJSON

extension SocketManager: WebSocketDelegate {
    public func websocketDidConnect(socket: WebSocketClient) {
        state.accept(.connected)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        state.accept(.disconnected(error?.toErrorAPI()))
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8),
            let json = try? JSON(data: data) {
            
            // Retrieve secret
            if let secret = json["params"]["secret"].string {
                Config.webSocketSecretKey = secret
                self.state.accept(.signed)
            }
        } else {
            state.accept(.message(text))
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        state.accept(.data(data))
    }
    
    public var text: Observable<String> {
        return state
            .observeOn(MainScheduler.asyncInstance)
            .filter {
                switch $0 {
                case .message:
                    return true
                default:
                    return false
                }
            }
            .map {
                switch $0 {
                case .message(let message):
                    return message
                default:
                    return String()
                }
            }
    }
}

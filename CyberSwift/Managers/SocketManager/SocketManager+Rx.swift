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
        state.accept(.disconnected(error?.cmError))
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        if let data = text.data(using: .utf8),
            let json = try? JSON(data: data),
            let secret = json["params"]["secret"].string
        {
            // Retrieve secret
            Config.webSocketSecretKey = secret
            state.accept(.signed)
        } else {
            textSubject.onNext(text)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
//        state.accept(.data(data))
    }
}

//
//  WebSocket+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import Starscream
import RxSwift
import RxCocoa

extension WebSocket: HasDelegate {
    public typealias Delegate = WebSocketDelegate
}

class RxWebSocketDelegateProxy: DelegateProxy<WebSocket, WebSocketDelegate>, DelegateProxyType, WebSocketDelegate {
    public weak private(set) var webSocket: WebSocket?
    
    public init(webSocket: ParentObject) {
        self.webSocket = webSocket
        super.init(parentObject: webSocket, delegateProxy: RxWebSocketDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {RxWebSocketDelegateProxy(webSocket: $0)}
    }
    
    fileprivate lazy var connect = PublishSubject<Bool>()
    func websocketDidConnect(socket: WebSocketClient) {
        connect.onNext(true)
        self.forwardToDelegate()?.websocketDidConnect(socket: socket)
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        connect.onNext(false)
        self.forwardToDelegate()?.websocketDidDisconnect(socket: socket, error: error)
    }
    
    fileprivate lazy var data = PublishSubject<Data>()
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.data.onNext(data)
        self.forwardToDelegate()?.websocketDidReceiveData(socket: socket, data: data)
    }
    
    fileprivate lazy var message = PublishSubject<String>()
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.message.onNext(text)
        self.forwardToDelegate()?.websocketDidReceiveMessage(socket: socket, text: text)
    }
    
    deinit {
        connect.onCompleted()
        data.onCompleted()
        message.onCompleted()
    }
}

extension Reactive where Base: WebSocket {
    public var delegate: DelegateProxy<WebSocket, WebSocketDelegate> {
        return RxWebSocketDelegateProxy.proxy(for: base)
    }
    
    var connected: Observable<Bool> {
        return (delegate as! RxWebSocketDelegateProxy).connect
    }
    
    var data: Observable<Data> {
        return (delegate as! RxWebSocketDelegateProxy).data
    }
    
    var message: Observable<String> {
        return (delegate as! RxWebSocketDelegateProxy).message
    }
}



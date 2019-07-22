//
//  StarScream+Rx.swift
//  CyberSwift
//
//  Created by Chung Tran on 23/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import Starscream

public enum WebSocketEvent {
    case connected
    case disconnected(Error?)
    case message(String)
    case data(Data)
    case pong
}

public class RxWebSocketDelegateProxy: WebSocketDelegate {
    fileprivate let subject = PublishSubject<WebSocketEvent>()
    let object: WebSocketClient
    
    public init(webSocket: WebSocketClient) {
        self.object = webSocket
        self.object.delegate = self
    }
    
    public func websocketDidConnect(socket: WebSocketClient) {
        subject.onNext(WebSocketEvent.connected)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        subject.onNext(WebSocketEvent.disconnected(error))
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        subject.onNext(WebSocketEvent.message(text))
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        subject.onNext(WebSocketEvent.data(data))
    }
    
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        subject.onNext(WebSocketEvent.pong)
    }
    
    deinit {
        subject.onCompleted()
    }
}

extension Reactive where Base: WebSocketClient {
    
    public var response: Observable<WebSocketEvent> {
        return RxWebSocketDelegateProxy(webSocket: base).subject
    }
    
    public var text: Observable<String> {
        return self.response
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
    
    public var connected: Observable<Bool> {
        return response
            .filter {
                switch $0 {
                case .connected, .disconnected:
                    return true
                default:
                    return false
                }
            }
            .map {
                switch $0 {
                case .connected:
                    return true
                default:
                    return false
                }
        }
    }
    
    public func write(data: Data) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(data: data) {
                sub.onNext(())
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    public func write(ping: Data) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(ping: ping) {
                sub.onNext(())
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    public func write(string: String) -> Observable<Void> {
        return Observable.create { sub in
            self.base.write(string: string) {
                sub.onNext(())
                sub.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

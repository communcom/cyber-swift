//
//  RxSwift.swift
//  CyberSwift
//
//  Created by Chung Tran on 23/05/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import RxSwift
import eosswift
import SwiftyJSON

extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait {
    public func flatMapToCompletable() -> Completable {
        return Completable.create { completable -> Disposable in
            return self.subscribe(onSuccess: { _ in
                completable(.completed)
            }, onError: { error in
                completable(.error(error))
            })
        }
    }
}

extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait, Self.ElementType == ChainResponse<TransactionCommitted> {
    func mapCachedError() -> Single<ChainResponse<TransactionCommitted>> {
        return map {response in
            if !response.success {
                var message = response.errorBody!.replacingOccurrences(of: "Optional(", with: "")
                
                if message.last == ")" {
                    message = String(message.dropLast())
                }
                
                
                Logger.log(message: message, event: .error)
                
                let json = try JSON(data: message.data(using: .utf8)!, options: .allowFragments)
                
                print(json.stringValue)
                
                let result = try JSONDecoder().decode(BCResponseAPIErrorResult.self, from: json.stringValue.data(using: .utf8)!)
                
                throw ErrorAPI.blockchain(message: result.error.details.first?.message ?? json.stringValue)
            }
            return response
        }
    }
}

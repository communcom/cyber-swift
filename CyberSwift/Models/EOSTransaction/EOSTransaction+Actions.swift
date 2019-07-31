//
//  EOSTransaction+Actions.swift
//  CyberSwift
//
//  Created by Chung Tran on 7/31/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import eosswift
import RxSwift

extension EOSTransaction {
    /// Send transaction, receive transaction_id
    func push(
        expirationDate: Date,
        actions: [ActionAbi],
        authorizingPrivateKey: EOSPrivateKey
    ) -> Single<String> {
        return chainApi().getInfo().flatMap { info -> Single<Decodable> in
            guard info.success,
                let chainID = info.body?.chain_id else {
                    throw ErrorAPI.couldNotRetrieveChainInfo
            }
            
            let transactionAbi = self.createTransactionAbi(expirationDate:      expirationDate,
                                                           blockIdDetails:      BlockIdDetails(blockId: info.body!.head_block_id),
                                                           actions:             actions)
            
            let signedTransactionAbi = SignedTransactionAbi(chainId:            ChainIdWriterValue(chainId: info.body!.chain_id),
                                                            transaction:        transactionAbi,
                                                            context_free_data:  HexCollectionWriterValue(value: []))
            
            let signature = PrivateKeySigning().sign(digest:                    signedTransactionAbi.toData(),
                                                     eosPrivateKey:             authorizingPrivateKey)
            
            // JSON
            let rrr = RequestAPITransaction(signatures: [signature],
                                            serializedTransaction: transactionAbi.toHex())
            
            
            // Prepare methodAPIType
            let methodAPIType = MethodAPIType.bandwidthProvide(chainID: chainID, transaction: rrr.convertToJSON())
            
            return Broadcast.instance.executeGetRequest(methodAPIType: methodAPIType)
        }
        .map {result -> String in
            guard let result = (result as? ResponseAPIBandwidthProvideResult)?.result else {
                throw ErrorAPI.unknown
            }
            return result.transaction_id
        }
    }
    
    private func createTransactionAbi(expirationDate:   Date,
                                      blockIdDetails:   BlockIdDetails,
                                      actions:          Array<ActionAbi>) -> TransactionAbi {
        return TransactionAbi(expiration:               TimestampWriterValue(date: expirationDate),
                              ref_block_num:            BlockNumWriterValue(value: blockIdDetails.blockNum),
                              ref_block_prefix:         BlockPrefixWriterValue(value: blockIdDetails.blockPrefix),
                              max_net_usage_words:      0,
                              max_cpu_usage_ms:         0,
                              max_ram_kbytes:           0,
                              max_storage_kbytes:       0,
                              delay_sec:                0,
                              context_free_actions:     [],
                              actions:                  actions,
                              transaction_extensions:   StringCollectionWriterValue(value: []))
    }
}

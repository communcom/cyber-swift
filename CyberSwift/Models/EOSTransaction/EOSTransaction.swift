//
//  EOSTransaction.swift
//  CyberSwift
//
//  Created by msm72 on 2/12/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import RxSwift
import Foundation
import eosswift

public class EOSTransaction {
    private let chainApi: ChainApi

    init(chainApi: ChainApi) {
        self.chainApi = chainApi
    }

    public func push(expirationDate: Date,
                     actions: [ActionAbi],
                     authorizingPrivateKey: EOSPrivateKey) -> Single<String> {
        return chainApi.getInfo().flatMap { info -> Single<ResponseAPIBandwidthProvide> in
                    guard info.success, let chainID = info.body?.chain_id else {
                        throw CMError.blockchainError(message: ErrorMessage.couldNotRetrieveChainInfo.rawValue, code: 0)
                    }

                    let transactionAbi = self.createTransactionAbi(expirationDate: expirationDate,
                            blockIdDetails: BlockIdDetails(blockId: info.body!.head_block_id),
                            actions: actions)

                    let signedTransactionAbi = SignedTransactionAbi(chainId: ChainIdWriterValue(chainId: info.body!.chain_id),
                            transaction: transactionAbi,
                            context_free_data: HexCollectionWriterValue(value: []))

                    let signature = PrivateKeySigning().sign(digest: try signedTransactionAbi.toData(),
                            eosPrivateKey: authorizingPrivateKey)

                    // JSON
                    let rrr = RequestAPITransaction(signatures: [signature],
                            serializedTransaction: transactionAbi.toHex())

                    // Prepare methodAPIType
                    let methodAPIType = MethodAPIType.bandwidthProvide(chainID: chainID,
                            transaction: rrr)

                    return RestAPIManager.instance.executeGetRequest(methodAPIType: methodAPIType, authorizationRequired: false) as Single<ResponseAPIBandwidthProvide>
                }
                .map { result -> String in
                    result.transaction_id
                }
                .do(onError: { (error) in
                    ErrorLogger.shared.recordError(error, additionalInfo: ["user": Config.currentUser?.id ?? "undefined"])
                    if let error = error as? ChainError {
                        Logger.log(message: "ChainAPI.getInfo error: \(error)", event: .debug)
                    }
                })
    }

    private func createTransactionAbi(expirationDate: Date,
                                      blockIdDetails: BlockIdDetails,
                                      actions: [ActionAbi]) -> TransactionAbi {
        TransactionAbi(expiration: TimestampWriterValue(date: expirationDate),
                ref_block_num: BlockNumWriterValue(value: blockIdDetails.blockNum),
                ref_block_prefix: BlockPrefixWriterValue(value: blockIdDetails.blockPrefix),
                max_net_usage_words: 0,
                max_cpu_usage_ms: 0,
                max_ram_kbytes: 0,
                max_storage_kbytes: 0,
                delay_sec: 0,
                context_free_actions: [],
                actions: actions,
                transaction_extensions: StringCollectionWriterValue(value: []))
    }
}

extension EOSArgument {

    struct CommunBandwidthProvider: Encodable {
        let provider: AccountNameWriterValue
        let account: AccountNameWriterValue
    }

}

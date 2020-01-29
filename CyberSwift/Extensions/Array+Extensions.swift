//
//  Array+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 4/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Checksum
import Foundation
import CryptoSwift

extension Array where Element == UInt8 {
    public func generateChecksumSha256() -> [UInt8] {
        var checksum: [UInt8] = self.sha256()
        checksum = checksum.sha256()

        return Array(checksum[0..<4])
    }

    public var base58EncodedString: String {
        guard !self.isEmpty else { return "" }
        return GSBase58.base58FromBytes(self)
    }
}

extension Sequence where Iterator.Element == ResponseAPIWalletGetBalance {
    public var enquityCommunValue: Double {
        reduce(0, {$0 + $1.communValue})
    }
}

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

extension Array where Element == Byte {
    public func generateChecksumSha256() -> [Byte] {
        var checksum: [Byte] = self.sha256()
        checksum = checksum.sha256()
        
        return Array(checksum[0..<4])
    }
    
    public var base58EncodedString: String {
        guard !self.isEmpty else { return "" }
        return GSBase58.base58FromBytes(self)
    }
}

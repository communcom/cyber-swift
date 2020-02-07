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
import RxDataSources

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

extension RangeReplaceableCollection where Element: IdentifiableType {
    public mutating func joinUnique(_ newElements: [Element]) {
        let newElements = newElements.filter {item in
            !self.contains(where: {$0.identity == item.identity})
        }
        self.append(contentsOf: newElements)
    }
    
    public func filterOut(_ elements: [Element]) -> Self {
        let newElements = self.filter {item in
            !elements.contains(where: {$0.identity == item.identity})
        }
        return newElements
    }
}

extension RangeReplaceableCollection where Element == ResponseAPIContentGetComment {
    public var sortedByTimeDesc: [ResponseAPIContentGetComment] {
        sorted { (comment1, comment2) -> Bool in
            let date1 = Date.from(string: comment1.meta.creationTime)
            let date2 = Date.from(string: comment2.meta.creationTime)
            return date1.compare(date2) == .orderedAscending
        }
    }
}

extension RangeReplaceableCollection where Element == ResponseAPIGetNotificationItem {
    public var sortedByTimestamp: [ResponseAPIGetNotificationItem] {
        sorted { (item1, item2) -> Bool in
            Date.from(string: item1.timestamp) > Date.from(string: item2.timestamp)
        }
    }
}

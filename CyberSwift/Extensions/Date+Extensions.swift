//
//  Date+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 2/4/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public enum DateFormatType: String {
    case commentDate                =   "dd-MM-yyyy"
    case expirationDateType         =   "yyyy-MM-dd'T'HH:mm:ss"
}

extension Date {
    public func convert(toStringFormat dateFormatType: DateFormatType) -> String {
        let dateFormatter           =   DateFormatter()
        dateFormatter.dateFormat    =   dateFormatType.rawValue
        dateFormatter.timeZone      =   TimeZone(identifier: "UTC")
        
        return dateFormatter.string(from: self)
    }
    
    public static func defaultTransactionExpiry(expireSeconds: Double = 0.0) -> Date {
        return Date(timeIntervalSince1970: (Date().timeIntervalSince1970) + 120.0 + expireSeconds)
    }
}

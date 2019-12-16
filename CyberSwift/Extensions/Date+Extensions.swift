//
//  Date+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 2/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

public enum DateFormatType: String {
    case commentDate                =   "dd-MM-yyyy"
    case nextSmsDateType            =   "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
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
    
    public func seconds(date: Date) -> Int {
        guard let seconds = Calendar.current.dateComponents([.second], from: self, to: date).second, seconds > 0 else { return 0 }
        return seconds
    }
    
    public func generateCurrentTimeStamp() -> String {
        return String(describing: UInt64(Date().timeIntervalSince1970))
    }
}

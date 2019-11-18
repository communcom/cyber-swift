//
//  String+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 4/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension String {
    var first: String {
        return String(prefix(1))
    }

    public func addFirstZero() -> String {
        return self.count == 1 ? "0" + self : self
    }

    public var uppercaseFirst: String {
        return first.uppercased() + String(dropFirst())
    }
    
    public static var latinLettersAndNumbers =
        Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

    public static func randomString(length: Int) -> String {
        return String((0..<length).map{ _ in latinLettersAndNumbers.randomElement()! })
    }
    
    public func removeWhitespaceCharacters() -> String {
        var result      =   NSMutableString.init(string: self)
        
        let pattern     =   "[\\s]+"
        let regex       =   try! NSRegularExpression(pattern: pattern)
        let matches     =   regex.matches(in: self, range: NSRange.init(location: 0, length: self.count))
        
        for match in matches.reversed() {
            result = result.replacingCharacters(in: match.range, with: " ") as! NSMutableString
        }
        
        return result as String
    }
    
    public func convert(toDateFormat dateFormatType: DateFormatType) -> Date {
        let dateFormatter           =   DateFormatter()
        dateFormatter.dateFormat    =   dateFormatType.rawValue
        dateFormatter.timeZone      =   TimeZone(identifier: "UTC")
        
        return dateFormatter.date(from: self)!
    }
    
    public static func permlinkWith(string: String) -> String {
        // transform all characters to ASCII
        let timestamp = Int(Date().timeIntervalSince1970)
        var components = string.components(separatedBy: "-")
        components.insert("re", at: 0)
        components.removeLast()
        components.append("\(timestamp)")
        let substring = components.joined(separator: "-").prefix(256)

        return String(substring)
    }
    
    public func trimSpaces() -> String {
        return self.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "")
    }
}

extension StringTransform {
    static let toLowercaseASCIINoSpaces =
        StringTransform(rawValue: "Any-Latin; Latin-ASCII; Lower; [:Separator:] Remove; [:^Letter:] Remove")
}

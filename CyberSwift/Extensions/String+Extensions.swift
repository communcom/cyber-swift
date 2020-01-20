//
//  String+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 4/12/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
        return String((0..<length).map { _ in latinLettersAndNumbers.randomElement()! })
    }
    
    // For currency only
    public var fullName: String {
        switch self {
        case Config.defaultSymbol:
            return "commun".localized().uppercaseFirst

        default:
            return self.localized().lowercased().uppercaseFirst
        }
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
    
    public static func permlinkWith(string: String, isComment: Bool = false) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)

        guard string.count > 0 else {
            return "\(timestamp)"
        }

        if isComment {
            if string.hasPrefix("re-") {
                var strings = string.components(separatedBy: "-")
                let perfix = string.hasPrefix("re-re-") ? "" : "re-"
                guard strings.count > 0 else { return perfix + "\(timestamp)" + "-" + "\(string)"}
                strings.removeLast()
                return perfix + strings.joined(separator: "-") + "-" + "\(timestamp)"
            } else {
                return "re-" + string + "-" + "\(timestamp)"
            }
        }

        // transform all characters to ASCII
        let transform1 = string.applyingTransform(.toLowercaseASCIINoSpaces, reverse: false)!
        
        // remove all unallowed characters
        let transform2 = String(transform1.filter {latinLettersAndNumbers.contains($0)})

        // get first 256 characters
        let substring = transform2.prefix(100)

        return "\(timestamp)" + "-" + "\(substring)"
    }
    
    public func trimSpaces() -> String {
        return self.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: "")
    }
}

extension StringTransform {
    static let toLowercaseASCIINoSpaces =
        StringTransform(rawValue: "Any-Latin; Latin-ASCII; Lower; [:Separator:] Remove; [:^Letter:] Remove")
}

//
//  String+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 4/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension String {
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        return String((0..<length).map{ _ in letters.randomElement()! })
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
}

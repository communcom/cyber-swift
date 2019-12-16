//
//  Encodable+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 3/5/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension Encodable {
    func convertToJSON() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        return jsonString
    }
}

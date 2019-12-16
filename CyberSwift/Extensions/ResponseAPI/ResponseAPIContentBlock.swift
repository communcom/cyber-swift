//
//  ResponseAPIContentBlock.swift
//  CyberSwift
//
//  Created by Chung Tran on 11/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension ResponseAPIContentBlock {
    public func jsonString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw ErrorAPI.invalidData(message: "Could not parse string from block")
        }
        return string
    }
    
    public func getTags() -> [String] {
        var tags = [String]()
        switch content {
        case .array(let childBlocks):
            for block in childBlocks {
                tags += block.getTags()
            }
        case .string(let string):
            if type == "tag" {
                return [string]
            }
        case .unsupported:
            break
        }
        return tags
    }
    
    public var thumbnailUrl: String? {
        if type == "image" {return content.stringValue}
        return attributes?.thumbnailUrl
    }
}

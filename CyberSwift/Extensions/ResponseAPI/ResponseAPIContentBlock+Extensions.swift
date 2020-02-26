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

public extension ResponseAPIContentBlockContent {
    var stringValue: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var arrayValue: [ResponseAPIContentBlock]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([ResponseAPIContentBlock].self) {
            self = .array(array)
            return
        }
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        
        self = .unsupported
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .array(let array):
            try container.encode(array)
        case .string(let string):
            try container.encode(string)
        case .unsupported:
            let context = EncodingError.Context(codingPath: [], debugDescription: "Invalid content")
            throw EncodingError.invalidValue(self, context)
        }
    }
}

public extension ResponseAPIContentBlockAttributes {
    init(embed: ResponseAPIFrameGetEmbed) {
        var type = embed.type
        if type == "photo" { type = "image" }
        if type == "link" { type = "website" }
        
        self.title          =   embed.title
        self.type           =   type
        self.version        =   nil
        self.style          =   nil
        self.textColor      =   nil
        self.url            =   embed.url
        self.description    =   embed.description
        self.providerName   =   embed.providerName
        self.author         =   embed.author
        self.authorUrl      =   embed.authorUrl
        self.thumbnailUrl   =   embed.thumbnailUrl
        self.thumbnailSize  =   nil
        self.html           =   embed.html
        self.coverUrl         =   nil
        self.thumbnailWidth   = embed.thumbnailWidth
        self.thumbnailHeight  = embed.thumbnailHeight
        self.width            = embed.thumbnailWidth
        self.height           = embed.thumbnailHeight
    }
}

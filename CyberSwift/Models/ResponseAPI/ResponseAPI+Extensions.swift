//
//  ResponseAPI+Extensions.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/9/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

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
        self.coverUrl       =   nil
    }
}

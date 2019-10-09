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
        self.text_color     =   nil
        self.url            =   embed.url
        self.description    =   embed.description
        self.provider_name  =   embed.provider_name
        self.author         =   embed.author
        self.author_url     =   embed.author_url
        self.thumbnail_url  =   embed.thumbnail_url
        self.thumbnail_size =   nil
        self.html           =   embed.html
    }
    
    init(
        title: String? = nil,
        type: String? = nil,
        version: String? = nil,
        style: [String]? = nil,
        text_color: String? = nil,
        url: String? = nil,
        description: String? = nil,
        provider_name: String? = nil,
        author: String? = nil,
        author_url: String? = nil,
        thumbnail_url: String? = nil,
        thumbnail_size: [UInt]? = nil,
        html: String? = nil
    ){
        self.title = title
        self.type = type
        self.version = version
        self.style = style
        self.text_color = text_color
        self.url = url
        self.description = description
        self.provider_name = provider_name
        self.author = author
        self.author_url = author_url
        self.thumbnail_url = thumbnail_url
        self.thumbnail_size = thumbnail_size
        self.html = html
    }

}

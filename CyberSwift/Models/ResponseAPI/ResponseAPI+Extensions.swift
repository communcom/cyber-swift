//
//  ResponseAPI+Extensions.swift
//  CyberSwift
//
//  Created by Chung Tran on 10/9/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public extension ResponseAPIContentGetPostContentBodyContent {
    var stringValue: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    var arrayValue: [ResponseAPIContentGetPostContentBody]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let array = try? container.decode([ResponseAPIContentGetPostContentBody].self) {
            self = .array(array)
            return
        }
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        
        self = .unsupported
    }
}

public extension ResponseAPIContentGetPostContentBodyAttributes {
//    init(embed: ResponseAPIFrameGetEmbed) {
//        self.title          =   embed.title
//        self.url            =   embed.url
//        self.description    =   embed.description
//        self.provider_name  =   embed.provider_name
//        self.author         =   embed.author
//        self.author_url     =   embed.author_url
//        self.thumbnail_url  =   embed.thumbnail_url
//        self.html           =   embed.html
//    }
}

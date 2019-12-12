//
//  UIImageCodable.swift
//  CyberSwift
//
//  Created by Chung Tran on 12/12/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

// Swift 4.0
public struct UIImageDumbDecodable: Decodable, Equatable {
    public let image: UIImage?
    
    public enum CodingKeys: String, CodingKey {
        case image
    }
    
    // Image is a standard UI/NSImage conditional typealias
    public init(image: UIImage?) {
        self.image = image
    }
    
    public init(from decoder: Decoder) throws {
        self.image = nil
    }
}

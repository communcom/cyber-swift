//
//  MockObjects.swift
//  Commun
//
//  Created by Chung Tran on 19/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
@testable import CyberSwift

extension Decodable {
    static func mockData() -> Self? {
        if let path = Bundle(for: GenerateKeysTests.self).path(forResource: String(describing: self), ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let result = try JSONDecoder().decode(ResponseAPIResult<Self>.self, from: data)
//                Logger.log(message: "Retrieved mocking objects for \(String(describing: self)): \(result)", event: .debug)
                return result.result
            } catch {
                print(error)
                // handle error
            }
        }
        return nil
    }
}

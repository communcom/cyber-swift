//
//  CurrentUser.swift
//  CyberSwift
//
//  Created by Chung Tran on 02/07/2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

public struct CurrentUser {
    // Main properties
    public let id: String
    public var name: String?
    public let activeKey: String
    
    // Registration keys
    public var registrationStep: String?
    public var phoneNumber: String?
    public var smsCode: UInt64?
    public var smsNextRetry: String?
    
    // UsersKey
    public var memoKeys: UserKeys?
    public var ownerKeys: UserKeys?
    public var activeKeys: UserKeys?
    public var postingKeys: UserKeys?
}

public struct UserKeys {
    public let privateKey: String
    public let publicKey: String
    
    init?(privateKey: String?, publicKey: String?){
        guard let privateKey = privateKey,
            let publicKey = publicKey else {
                return nil
        }
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

//
//  ResponseAPI+Promo.swift
//  CyberSwift
//
//  Created by Chung Tran on 3/19/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPISettingsGetUserSettings: Decodable {
    public var system: ResponseAPISettingsGetUserSettingsSystem?
    public var user: ResponseAPISettingsGetUserSettingsUser?
}

public struct ResponseAPISettingsGetUserSettingsSystem: Decodable {
    public var airdrop: ResponseAPISettingsGetUserSettingsSystemAirdrop?
}

public struct ResponseAPISettingsGetUserSettingsSystemAirdrop: Decodable {
    public var claimed: [String]?
}

public struct ResponseAPISettingsGetUserSettingsUser: Decodable {
}

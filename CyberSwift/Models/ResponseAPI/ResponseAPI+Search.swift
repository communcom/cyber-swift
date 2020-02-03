//
//  ResponseAPI+Search.swift
//  CyberSwift
//
//  Created by Chung Tran on 2/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

public struct ResponseAPIContentQuickSearch: Decodable {
    public let items: [ResponseAPIContentSearchItem]
    public let total: UInt
}

public enum ResponseAPIContentSearchItem: ListItemType {
    public func newUpdatedItem(from item: ResponseAPIContentSearchItem) -> ResponseAPIContentSearchItem? {
        guard item.identity == self.identity else {return nil}
        switch self {
        case .profile(let profileSelf):
            guard let newProfile = item.profileValue else {return nil}
            guard let updatedProfile = profileSelf.newUpdatedItem(from: newProfile) else {
                return nil
            }
            return ResponseAPIContentSearchItem.profile(updatedProfile)
        case .community(let communitySelf):
            guard let newItem = item.communityValue else {return nil}
            guard let updatedItem = communitySelf.newUpdatedItem(from: newItem) else {
                return nil
            }
            return ResponseAPIContentSearchItem.community(updatedItem)
        case .post(let postSelf):
            guard let newItem = item.postValue else {return nil}
            guard let updatedItem = postSelf.newUpdatedItem(from: newItem) else {
                return nil
            }
            return ResponseAPIContentSearchItem.post(updatedItem)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let user = try? container.decode(ResponseAPIContentGetProfile.self) {
            self = .profile(user)
            return
        }
        if let community = try? container.decode(ResponseAPIContentGetCommunity.self) {
            self = .community(community)
            return
        }
        if let post = try? container.decode(ResponseAPIContentGetPost.self) {
            self = .post(post)
            return
        }
        throw ErrorAPI.unsupported
    }
    
    case profile(ResponseAPIContentGetProfile)
    case community(ResponseAPIContentGetCommunity)
    case post(ResponseAPIContentGetPost)
    
    public var identity: String {
        switch self {
        case .profile(let profile):
            return profile.identity
        case .community(let community):
            return community.identity
        case .post(let post):
            return post.identity
        }
    }
    
    public var profileValue: ResponseAPIContentGetProfile? {
        switch self {
        case .profile(let profile):
            return profile
        default:
            return nil
        }
    }
    
    public var communityValue: ResponseAPIContentGetCommunity? {
        switch self {
        case .community(let community):
            return community
        default:
            return nil
        }
    }
    
    public var postValue: ResponseAPIContentGetPost? {
        switch self {
        case .post(let post):
            return post
        default:
            return nil
        }
    }
}

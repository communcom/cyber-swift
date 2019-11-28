//
//  ResponseAPIOnlineNotificationData.swift
//  Commun
//
//  Created by Chung Tran on 31/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

extension ResponseAPIOnlineNotificationData: IdentifiableType {
    public var identity: String {
        return self._id
    }
}

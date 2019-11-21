//
//  Numbers+Extensions.swift
//  CyberSwift
//
//  Created by Sergey Monastyrskiy on 21.11.2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation

extension CGFloat {
    public static func adaptive(width: CGFloat) -> CGFloat {
        return width * Config.widthRatio
    }

    public static func adaptive(height: CGFloat) -> CGFloat {
        return height * Config.heightRatio
    }
}

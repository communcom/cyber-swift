//
//  Numbers+Extensions.swift
//  CyberSwift
//
//  Created by Sergey Monastyrskiy on 21.11.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
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

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        return formatter
    }()
}

extension UInt64 {
    public var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

extension FloatingPoint {
    public var whole: Self { modf(self).0 }
    public var fraction: Self { modf(self).1 }
    
    public var formattedWithSeparator: String {
        guard self >= 1_000 else { return "\(self)" }
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

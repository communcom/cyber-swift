//
//  UIView+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 5/14/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import Foundation
import SwiftTheme

public enum ShadowLocation: String {
    case top
    case bottom
}

extension UIView {
    public func tune() {
        self.theme_backgroundColor  =   whiteVeryDarkGrayishRedPickers
    }

    public func addShadow(location: ShadowLocation = .top, height: CGFloat = 10.0, color: UIColor = .gray, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
            addShadow(offset:       CGSize(width: 0, height: height),
                      color:        color,
                      opacity:      opacity,
                      radius:       radius)
        
        case .top:
            addShadow(offset:       CGSize(width: 0, height: -height),
                      color:        color,
                      opacity:      opacity,
                      radius:       radius)
        }
    }
    
    private func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
        layer.masksToBounds         =   false
        layer.shadowColor           =   color.cgColor
        layer.shadowOpacity         =   opacity
        layer.shadowRadius          =   radius
        layer.shadowOffset          =   offset
        layer.bounds                =   self.bounds
    }
}

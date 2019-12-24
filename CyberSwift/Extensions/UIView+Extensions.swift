//
//  UIView+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 5/14/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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
            addShadow(offset: CGSize(width: 0, height: height),
                      color: color,
                      opacity: opacity,
                      radius: radius)
        
        case .top:
            addShadow(offset: CGSize(width: 0, height: -height),
                      color: color,
                      opacity: opacity,
                      radius: radius)
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
    
    // https://developer.apple.com/documentation/quartzcore/cashapelayer/1521921-linedashpattern#2825197
    public func draw(lineColor color: UIColor = .lightGray, lineWidth width: CGFloat = 1.0, startPoint start: CGPoint, endPoint end: CGPoint, withDashPattern lineDashPattern: [NSNumber]? = nil) {
        // Example of lineDashPattern: [nil, [2,3], [10, 5, 5, 5]]
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = width
        shapeLayer.lineDashPattern = lineDashPattern
        
        let path = CGMutablePath()
        path.addLines(between: [start, end])
        shapeLayer.path = path
        
        layer.addSublayer(shapeLayer)
    }
    
    public func copyView() -> UIView? {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView
    }
}

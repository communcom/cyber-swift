//
//  UILabel+Extensions.swift
//  Golos
//
//  Created by msm72 on 09.06.2018.
//  Copyright © 2018 golos. All rights reserved.
//

import UIKit
import SwiftTheme

extension UILabel {
    public func tune(withText text: String, hexColors: ThemeColorPicker?) {
        self.text               =   text.localized()
        self.theme_textColor    =   hexColors
    }
    
    public func tune(withText text: String, hexColors: ThemeColorPicker?, font: UIFont?, alignment: NSTextAlignment, isMultiLines: Bool) {
        self.text               =   text.localized()
        self.font               =   font
        self.theme_textColor    =   hexColors
        
        self.numberOfLines      =   isMultiLines ? 0 : 1
        self.textAlignment      =   alignment
    }
    
    public func tune(withAttributedText text: String,
                     hexColors: ThemeColorPicker?,
                     font: UIFont?,
                     alignment: NSTextAlignment,
                     isMultiLines: Bool,
                     lineSpacing: CGFloat = 1.3,
                     lineHeight: CGFloat = 26) {
        ThemeManager.setTheme(index: Config.isAppThemeDark ? 1 : 0)
        
        let attributedString    =   NSMutableAttributedString(string:      text.localized(),
                                                              attributes:  [ NSAttributedString.Key.font: font! ])
        
        let style               =   NSMutableParagraphStyle()
        style.lineSpacing       =   lineSpacing * Config.widthRatio
        style.minimumLineHeight =   lineHeight * Config.widthRatio
        
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: style], range: NSRange(location: 0, length: text.localized().count))
        self.attributedText     =   attributedString
        
        self.font               =   font
        self.theme_textColor    =   hexColors
        
        self.numberOfLines      =   isMultiLines ? 0 : 1
        self.textAlignment      =   alignment
    }
}

//
//  UITextField+Extensions.swift
//  Golos
//
//  Created by msm72 on 11.06.2018.
//  Copyright © 2018 Commun Limited. All rights reserved.
//

import UIKit
import SwiftTheme

extension UITextField {
    public func tune(withPlaceholder placeholder: String, textColors: ThemeColorPicker?, font: UIFont?, alignment: NSTextAlignment) {
        self.font                   =   font
        self.theme_textColor        =   textColors
        self.textAlignment          =   alignment
        
        self.attributedPlaceholder  =   NSAttributedString(string: placeholder.localized().uppercaseFirst,
                                                           attributes: [ NSAttributedString.Key.foregroundColor: UIColor(hexString: "#A5A7BD") ])
    }
    
    public func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView     =   UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView       =   paddingView
        self.leftViewMode   =   .always
    }
}

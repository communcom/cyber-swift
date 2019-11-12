//
//  UITextView+Extensions.swift
//  CyberSwift
//
//  Created by Sergey Monastyrskiy on 12.11.2019.
//  Copyright © 2019 golos.io. All rights reserved.
//

import UIKit
import SwiftTheme

extension UITextField {
    public func tune(withTextColors textColors: ThemeColorPicker?, font: UIFont?, alignment: NSTextAlignment) {
        self.font                   =   font
        self.theme_textColor        =   textColors
        self.textAlignment          =   alignment
    }
}

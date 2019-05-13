//
//  UIButton+Extensions.swift
//  golos-ios
//
//  Created by Grigory Serebryanyy on 13/01/2018.
//  Copyright © 2018 golos. All rights reserved.
//

import UIKit
import SwiftTheme

extension UIButton {    
    /// hexColors: [normal, highlighted, selected, disabled]
    func tune(withTitle title: String, hexColors: [ThemeColorPicker], font: UIFont?, alignment: NSTextAlignment) {
        self.titleLabel?.font               =   font
        self.titleLabel?.textAlignment      =   alignment
        self.contentMode                    =   .scaleAspectFill

        self.setTitle(title.localized(), for: .normal)
        self.theme_setTitleColor(hexColors[0], forState: .normal)
        self.theme_setTitleColor(hexColors[1], forState: .highlighted)
        self.theme_setTitleColor(hexColors[2], forState: .selected)
        self.theme_setTitleColor(hexColors[3], forState: .disabled)
    }
    
    func setBlueButtonRoundEdges() {
        self.layoutIfNeeded()
        setRoundEdges(cornerRadius: self.frame.height / 2)

        self.titleLabel?.font       =   UIFont(name: "SFProDisplay-Regular", size: 16.0)
        self.theme_backgroundColor  =   vividBlueWhiteColorPickers
        self.theme_setTitleColor(whiteColorPickers, forState: .normal)
    }
    
    func fill(colorPicker: ThemeColorPicker = vividBlueColorPickers, cornerRadius: CGFloat = 5.0, font: UIFont = UIFont(name: "SFProDisplay-Regular", size: 16.0)!) {
        self.layoutIfNeeded()
        
        self.titleLabel?.font       =   font
        self.theme_backgroundColor  =   colorPicker

        self.setRoundEdges(cornerRadius: cornerRadius)
        self.theme_setTitleColor(whiteColorPickers, forState: .normal)
    }
    
    func setBorder(color: CGColor, cornerRadius: CGFloat) {
        self.layoutIfNeeded()
        setRoundEdges(cornerRadius: cornerRadius)
        
        self.layer.borderColor      =   color
        self.layer.borderWidth      =   1.0
        self.theme_backgroundColor  =   whiteVeryDarkGrayPickers
    }
    
    func setBorderButtonRoundEdges() {
        self.layoutIfNeeded()
        setRoundEdges(cornerRadius: self.frame.height / 2)

        self.layer.borderColor      =   UIColor(hexString: "#DBDBDB").cgColor
        self.layer.borderWidth      =   1.0
        self.titleLabel?.font       =   UIFont(name: "SFProDisplay-Regular", size: 16.0)
        self.theme_backgroundColor  =   whiteColorPickers
        self.theme_setTitleColor(darkGrayWhiteColorPickers, forState: .normal)
    }
        
    private func setRoundEdges(cornerRadius: CGFloat) {
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    
    // For Like / Dislike buttons
    func startLikeVote(withSpinner spinner: UIActivityIndicatorView) {
        self.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            spinner.startAnimating()
            self.setImage(UIImage(named: Config.isAppThemeDark ? "icon-button-active-vote-dark-empty" : "icon-button-active-vote-white-empty"), for: .normal)
        }
    }
    
    func breakLikeVote(withSpinner spinner: UIActivityIndicatorView) {
        self.isEnabled = true
        spinner.stopAnimating()
    }
}

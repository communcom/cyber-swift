//
//  UIImage+Extensions.swift
//  CyberSwift
//
//  Created by msm72 on 5/30/19.
//  Copyright © 2019 commun.io. All rights reserved.
//

import UIKit

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
    
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func resize(_ maxSide: CGFloat = 1280) -> UIImage? {
        var image = self

        if size.width > maxSide || size.height > maxSide {
            let proportion = size.width >= size.height ? size.width / maxSide : size.height / maxSide
            let finalRect = CGRect(x: 0, y: 0, width: size.width / proportion, height: size.height / proportion)
            UIGraphicsBeginImageContextWithOptions(finalRect.size, false, 1.0)
            draw(in: finalRect)
            image = UIGraphicsGetImageFromCurrentImageContext() ?? self
            UIGraphicsEndImageContext()
        }

        if let imageData = image.jpegData(compressionQuality: 0.7) {
            let finalImage = UIImage(data: imageData) ?? image
            return finalImage
        }

        return nil
    }
}

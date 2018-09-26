//
//  UIImageView+Extension.swift
//  KinoPub
//
//  Created by Евгений Дац on 24/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

extension UIImageView {
    func processImage(image: UIImage, withSize size: CGSize) -> UIImage {
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.contentsGravity = CALayerContentsGravity(rawValue: "resizeAspectFill")
        layer.contents = image.cgImage
        UIGraphicsBeginImageContext(size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return processedImage!
    }
    
    func roundImage(_ radius: CGFloat) {
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.contentsGravity = CALayerContentsGravity(rawValue: "resizeAspectFill")
        layer.contents = self.image?.cgImage
        UIGraphicsBeginImageContext(size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.image = processedImage
    }
}

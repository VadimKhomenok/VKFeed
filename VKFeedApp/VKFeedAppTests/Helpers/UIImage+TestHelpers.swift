//
//  UIImage+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

extension UIImage {
    static func makeTinyImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

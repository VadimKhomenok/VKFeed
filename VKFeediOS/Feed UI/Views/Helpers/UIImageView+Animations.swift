//
//  UIImageView+Animations.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 15.05.22.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}

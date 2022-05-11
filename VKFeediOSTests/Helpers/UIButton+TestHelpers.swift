//
//  UIButton+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}

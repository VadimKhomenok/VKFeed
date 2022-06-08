//
//  UIView+TestHelpers.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 9.06.22.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}

//
//  UIButton+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}

//
//  UIViewController+Refreshing.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 23.05.22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}

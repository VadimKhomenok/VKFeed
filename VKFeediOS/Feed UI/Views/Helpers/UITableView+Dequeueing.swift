//
//  UITableView+Dequeueing.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 15.05.22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let reuseIdentifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: reuseIdentifier) as! T
    }
}

//
//  CellController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 22.06.22.
//

import UIKit

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

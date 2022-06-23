//
//  ImageCommentCellController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 23.06.22.
//

import UIKit
import VKFeed

public final class ImageCommentCellController: CellController {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageCommentCell.self)) as! ImageCommentCell
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}

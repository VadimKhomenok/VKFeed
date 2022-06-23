//
//  ImageCommentCellController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 23.06.22.
//

import UIKit
import VKFeed

public final class ImageCommentCellController: NSObject, UITableViewDataSource {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageCommentCell.self)) as! ImageCommentCell
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}

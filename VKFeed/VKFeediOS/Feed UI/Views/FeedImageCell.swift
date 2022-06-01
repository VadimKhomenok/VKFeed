//
//  FeedImageCell.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 8.05.22.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped() {
        onRetry?()
    }
}

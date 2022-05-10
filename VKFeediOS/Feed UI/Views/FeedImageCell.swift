//
//  FeedImageCell.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 8.05.22.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let locationContainer = UIView()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    
    var onRetry: (() -> Void)?
    
    private(set) public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}

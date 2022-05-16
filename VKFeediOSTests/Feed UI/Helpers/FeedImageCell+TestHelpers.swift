//
//  FeedImageCell+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeediOS
import Foundation

extension FeedImageCell {
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var locationIsVisible: Bool {
        return !locationContainer.isHidden
    }
    
    var descriptionIsVisible: Bool {
        return !descriptionLabel.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var isShowingRetryButton: Bool {
        return !retryButton.isHidden
    }
    
    func simulateFeedImageViewRetry() {
        retryButton.simulateTap()
    }
}

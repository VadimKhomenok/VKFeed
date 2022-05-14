//
//  FeedImageCellController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import UIKit

final class FeedImageCellController {
    private let feedImageViewModel: FeedImageViewModel
    
    init(feedImageViewModel: FeedImageViewModel) {
        self.feedImageViewModel = feedImageViewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        feedImageViewModel.loadImage()
        return cell
    }
    
    private func binded(_ view: FeedImageCell) -> FeedImageCell {
        view.descriptionLabel.text = feedImageViewModel.description
        view.locationLabel.text = feedImageViewModel.location
        view.locationContainer.isHidden = feedImageViewModel.isLocationHidden
        view.descriptionLabel.isHidden = feedImageViewModel.isDescriptionHidden
        view.onRetry = feedImageViewModel.loadImage
        
        feedImageViewModel.onImageLoad = { [weak view] loadedImage in
            view?.feedImageView.image = loadedImage
        }
        
        feedImageViewModel.onImageLoadingStateChange = { [weak view] isLoading in
            view?.feedImageContainer.isShimmering = isLoading
        }
        
        feedImageViewModel.onShouldRetryImageLoadStateChange = { [weak view] shouldRetry in
            view?.retryButton.isHidden = !shouldRetry
        }
        
        return view
    }
    
    func preload() {
        feedImageViewModel.loadImage()
    }
    
    func cancelLoad() {
        feedImageViewModel.cancelLoad()
    }
}

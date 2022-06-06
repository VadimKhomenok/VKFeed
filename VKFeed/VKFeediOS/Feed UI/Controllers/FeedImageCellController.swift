//
//  FeedImageCellController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import UIKit

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
    private var cell: FeedImageCell?
    
    var delegate: FeedImageCellControllerDelegate
    
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    public func display(_ viewModel: FeedImageViewModel<UIImage>) {
        cell?.descriptionLabel.text = viewModel.description
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.descriptionLabel.isHidden = !viewModel.hasDescription
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageView.setImageAnimated(viewModel.image)
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
        cell?.retryButton.isHidden = !viewModel.isRetry
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellForReuse()
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}

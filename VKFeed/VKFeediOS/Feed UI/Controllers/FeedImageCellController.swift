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

public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView, ResourceLoadErrorView {
    public typealias ResourceViewModel = UIImage
    
    private let viewModel: FeedImageViewModel
    private var cell: FeedImageCell?
    
    var delegate: FeedImageCellControllerDelegate
    
    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.descriptionLabel.text = viewModel.description
        cell?.locationLabel.text = viewModel.location
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.descriptionLabel.isHidden = !viewModel.hasDescription
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ viewModel: UIImage) {
        cell?.feedImageView.setImageAnimated(viewModel)
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: ResourceLoadErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
    
    public func preload() {
        delegate.didRequestImage()
    }
    
    public func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellForReuse()
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}

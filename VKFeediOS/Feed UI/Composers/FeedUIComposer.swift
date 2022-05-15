//
//  FeedUIComposer.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import Foundation
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(imageLoader: FeedImageDataLoader, feedLoader: FeedLoader) -> FeedViewController {
        let feedViewPresenter = FeedViewPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(feedViewPresenter: feedViewPresenter)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewPresenter.feedLoadingView = WeakRefVirtualProxy(object: refreshController)
        feedViewPresenter.feedView = FeedViewAdapter(feedViewController: feedViewController, loader: imageLoader)
        
        return feedViewController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(feedViewController: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = feedViewController
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(feedImageViewModel: FeedImageViewModel(imageLoader: loader, feedModel: model, imageTransformer: UIImage.init))
        }
    }
}

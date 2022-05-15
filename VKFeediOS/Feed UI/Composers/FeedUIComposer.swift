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
        let presenter = FeedViewPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(presenter: presenter, feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(loadFeed: presentationAdapter.loadFeed)
        let feedViewController = FeedViewController(refreshController: refreshController)
        presenter.feedLoadingView = WeakRefVirtualProxy(object: refreshController)
        presenter.feedView = FeedViewAdapter(feedViewController: feedViewController, loader: imageLoader)
        
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

final class FeedLoaderPresentationAdapter {
    private let presenter: FeedViewPresenter
    private let feedLoader: FeedLoader
    
    init(presenter: FeedViewPresenter, feedLoader: FeedLoader) {
        self.presenter = presenter
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        feedLoader.load(completion: { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        })
    }
}

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
        feedViewPresenter.feedLoadingView = refreshController
        feedViewPresenter.feedView = FeedViewAdapter(feedViewController: feedViewController, loader: imageLoader)
        
        return feedViewController
    }
}

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(feedViewController: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = feedViewController
        self.loader = loader
    }
    
    func display(feed: [FeedImage]) {
        controller?.tableModel = feed.map { model in
            FeedImageCellController(feedImageViewModel: FeedImageViewModel(imageLoader: loader, feedModel: model, imageTransformer: UIImage.init))
        }
    }
}

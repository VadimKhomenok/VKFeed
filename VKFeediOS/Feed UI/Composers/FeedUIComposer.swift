//
//  FeedUIComposer.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import Foundation

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(imageLoader: FeedImageDataLoader, feedLoader: FeedLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.refreshComplete = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
        
        return feedViewController
    }
}

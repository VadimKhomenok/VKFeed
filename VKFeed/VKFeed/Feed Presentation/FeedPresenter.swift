//
//  FeedPresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 24.05.22.
//

import Foundation

public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let feedErrorView: FeedErrorView
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(feedLoadingView: FeedLoadingView, feedView: FeedView, feedErrorView: FeedErrorView) {
        self.loadingView = feedLoadingView
        self.feedView = feedView
        self.feedErrorView = feedErrorView
    }
    
    public func didStartLoadingFeed() {
        feedErrorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(Self.map(feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        feedErrorView.display(.error(message: feedLoadError))
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        return FeedViewModel(feed: feed)
    }
}

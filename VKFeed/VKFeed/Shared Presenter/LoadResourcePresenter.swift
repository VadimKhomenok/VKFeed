//
//  LoadResourcePresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 18.06.22.
//

import Foundation

public final class LoadResourcePresenter {
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
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
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
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        feedErrorView.display(.error(message: feedLoadError))
    }
}

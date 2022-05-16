//
//  FeedViewPresenter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 15.05.22.
//

import Foundation

import VKFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
    var loadingView: FeedLoadingView
    var feedView: FeedView
    
    static var title: String {
        return "My Feed"
    }
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.loadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}

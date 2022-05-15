//
//  FeedViewPresenter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 15.05.22.
//

import Foundation

import VKFeed

struct FeedLoadingViewModel {
    var isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    var feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedViewPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(feedLoader: FeedLoader){
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            
            self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        })
    }
}

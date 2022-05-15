//
//  FeedViewPresenter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 15.05.22.
//

import Foundation

import VKFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedViewPresenter {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    weak var feedLoadingView: (AnyObject & FeedLoadingView)?
    var feedView: FeedView?
    
    init(feedLoader: FeedLoader){
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            
            self?.feedLoadingView?.display(isLoading: false)
        })
    }
}

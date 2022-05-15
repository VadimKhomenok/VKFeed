//
//  FeedViewModel.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 14.05.22.
//

import VKFeed

final class FeedViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: Observer<[FeedImage]>?
    var onLoadingStateChanged: Observer<Bool>?
    
    func loadFeed() {
        onLoadingStateChanged?(true)
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            
            self?.onLoadingStateChanged?(false)
        })
    }
}

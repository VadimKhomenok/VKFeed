//
//  FeedViewModel.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 14.05.22.
//

import VKFeed

class FeedViewModel {
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onFeedLoad: (([FeedImage]) -> Void)?
    var onChangeState: ((FeedViewModel) -> Void)?
    
    var isLoading: Bool = false {
        didSet { onChangeState?(self) }
    }
    
    func loadFeed() {
        isLoading = true
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            
            self?.isLoading = false
        })
    }
}

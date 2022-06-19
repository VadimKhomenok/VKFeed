//
//  FeedLoaderPresentationAdapter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 18.05.22.
//

import VKFeed
import VKFeediOS
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    private let feedLoader: () -> LocalFeedLoader.Publisher
    
    private var cancellable: Cancellable?
    
    init(feedLoader: @escaping () -> LocalFeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
                
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] feed in
            self?.presenter?.didFinishLoading(with: feed)
        }
    }
}

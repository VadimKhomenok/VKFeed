//
//  FeedImageDataLoaderCacheDecorator.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 4.06.22.
//

import VKFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.saveIgnoringResult(data, for: url)
                return data
            })
        }
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

//
//  LocalFeedLoader.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.04.22.
//

import Foundation

public class LocalFeedLoader {
    private var store: FeedStore
    private var currentDate: Date

    public typealias SaveResult = Error?
    public typealias LoadResult = FeedLoader.Result
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
}
 

// MARK: - Local Feed Loader Save

extension LocalFeedLoader {
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache() { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

// MARK: - Local Feed Loader Load

extension LocalFeedLoader: FeedLoader {
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate):
                completion(.success(cache.feed.toModel()))
            case .success:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}


// MARK: - Local Feed Loader Validation

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate):
                self.store.deleteCache { _ in }
            case .failure(_):
                self.store.deleteCache { _ in }
            case .success:
                break
            }
        }
    }
}

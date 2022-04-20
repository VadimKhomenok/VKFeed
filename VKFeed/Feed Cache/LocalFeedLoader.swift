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

    public typealias LoadResult = FeedLoaderResult
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(feed, completion: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModel()))
            case .found, .empty:
                completion(.success([]))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.insert(feed.toLocal(), timestamp: self.currentDate, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let currentDate = Date()
        guard let sevenDaysOldTimestamp = Calendar(identifier: .gregorian).date(byAdding: .day, value: -7, to: currentDate) else {
            return false
        }
        
        return timestamp > sevenDaysOldTimestamp
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

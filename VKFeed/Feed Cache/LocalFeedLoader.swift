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
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [weak self] deletionError in
            guard let self = self else { return }
            
            if let deletionError = deletionError {
                completion(deletionError)
            } else {
                self.cache(items, completion: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], completion:  @escaping (Error?) -> Void) {
        store.insert(items: items, timestamp: self.currentDate, completion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

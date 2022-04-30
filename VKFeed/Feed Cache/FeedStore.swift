//
//  FeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.04.22.
//

import Foundation

public enum CachedFeed {
    case found(feed: [LocalFeedImage], timestamp: Date)
    case empty
}

public protocol FeedStore {
    typealias RetrievalResult = Result<CachedFeed, Error>
    
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCache(_ completion: @escaping DeletionCompletion)
}

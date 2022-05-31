//
//  CoreDataFeedStore+FeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 1.06.22.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion( Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            completion( Result {
                try ManagedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func deleteCache(_ completion: @escaping DeletionCompletion) {
        perform { context in
            completion( Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
}

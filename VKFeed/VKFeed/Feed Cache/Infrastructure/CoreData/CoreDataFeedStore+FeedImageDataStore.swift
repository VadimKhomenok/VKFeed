//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 31.05.22.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }
    
    public func insert(_ imageData: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = imageData }
                    .map(context.save)
            }
        }
    }
}

//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 31.05.22.
//

import Foundation

extension CoreDataFeedStore {
    public func retrieve(dataForURL: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
}

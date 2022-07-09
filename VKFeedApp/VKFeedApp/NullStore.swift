//
//  NullStore.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 9.07.22.
//

import VKFeed

class NullStore: FeedStore {
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func deleteCache(_ completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
}

extension NullStore: FeedImageDataStore {
    func insert(_ imageData: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
}

//
//  NullStore.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 9.07.22.
//

import VKFeed

class NullStore: FeedStore & FeedImageDataStore {
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func deleteCache(_ completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ imageData: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
    
    
}

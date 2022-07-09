//
//  FeedImageDataStoreSpy.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 31.05.22.
//

import Foundation
import VKFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    
    enum ReceivedMessages: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var messages = [ReceivedMessages]()
    private(set) var retrievalResult: Result<Data?, Error>?
    private(set) var insertionResult: Result<Void, Error>?
    
    func insert(_ imageData: Data, for url: URL) throws {
        messages.append(.insert(data: imageData, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        messages.append(.retrieve(dataFor: url))
        return try retrievalResult?.get()
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
}

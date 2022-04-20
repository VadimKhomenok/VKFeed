//
//  FeedStoreSpy.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 20.04.22.
//

import VKFeed

class FeedStoreSpy: FeedStore {
    enum ReceivedMessages: Equatable {
        case insert([LocalFeedImage], Date)
        case retrieve
        case deleteCachedFeed
    }
    
    var messages = [ReceivedMessages]()
    
    var insertionCompletions: [InsertionCompletion] = []
    var deletionCompletions: [DeletionCompletion] = []
    var retrievalCompletions: [RetrievalCompletion] = []
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        messages.append(.insert(feed, timestamp))
        insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        messages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func deleteCache(_ completion: @escaping DeletionCompletion) {
        messages.append(.deleteCachedFeed)
        deletionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionWithSuccess(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
   
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](error)
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](nil)
    }
}


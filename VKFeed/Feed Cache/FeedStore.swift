//
//  FeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.04.22.
//

import Foundation

public protocol FeedStore {
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (Error?) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
    func deleteCache(_ completion: @escaping DeletionCompletion)
}

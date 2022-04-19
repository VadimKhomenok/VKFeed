//
//  CacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.04.22.
//

import XCTest
import VKFeed

class FeedStore {
    var deleteCallsCount = 0
    
    func deleteCache() {
        deleteCallsCount += 1
    }
}

class CacheFeedLoader {
    private var store: FeedStore
    
    init(store: FeedStore = FeedStore()) {
        self.store = store
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_deleteCache_notCalledOnInit() {
        let store = FeedStore()
        let _ = CacheFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCallsCount, 0)
    }
}

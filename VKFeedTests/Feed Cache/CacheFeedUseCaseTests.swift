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

class LocalFeedLoader {
    private var store: FeedStore
    
    init(store: FeedStore = FeedStore()) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheOnCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCallsCount, 0)
    }
    
    func test_save_triggersCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        let items = [makeUniqueItem(), makeUniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCallsCount, 1)
    }
    
    // MARK: - Helpers
    
    func makeUniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageUrl: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
}

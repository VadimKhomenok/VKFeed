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
    
    func save(items: [FeedItem]) {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_deleteCache_notCalledOnInit() {
        let store = FeedStore()
        let _ = CacheFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCallsCount, 0)
    }
    
    func test_saveCache_triggersDeleteOnStore() {
        let store = FeedStore()
        let sut = CacheFeedLoader(store: store)
        
        let items = [makeUniqueFeedItem(), makeUniqueFeedItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCallsCount, 1)
    }
    
    // MARK: - Helpers
    
    func makeUniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageUrl: anyURL())
    }
    
    func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
}

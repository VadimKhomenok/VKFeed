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
    var insertCallsCount = 0
    
    func deleteCache() {
        deleteCallsCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int) {

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
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCallsCount, 0)
    }
    
    func test_save_triggersCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [makeUniqueItem(), makeUniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCallsCount, 1)
    }
    
    func test_save_notInsertingItemsOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [makeUniqueItem(), makeUniqueItem()]
        sut.save(items: items)
        store.completeDeletion(with: anyNSError(), at: 0)
        
        XCTAssertEqual(store.insertCallsCount, 0)
    }
    
    // MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
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

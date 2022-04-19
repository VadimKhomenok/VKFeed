//
//  CacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.04.22.
//

import XCTest
import VKFeed

typealias DeletionCompletion = (Error?) -> Void

class FeedStore {
    var deleteCallsCount = 0
    var insertCallsCount = 0
    
    var deletionCompletions: [DeletionCompletion] = []
    
    func insert(items: [FeedItem]) {
        insertCallsCount += 1
    }
    
    func deleteCache(_ completion: @escaping DeletionCompletion) {
        deleteCallsCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionWithSuccess(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
}

class LocalFeedLoader {
    private var store: FeedStore
    
    init(store: FeedStore = FeedStore()) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCache() { [unowned self] error in
            if error == nil {
                self.store.insert(items: items)
            }
        }
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
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.insertCallsCount, 0)
    }
    
    func test_save_insertingOfItemsOnSuccessfulCacheDeletion() {
        let (sut, store) = makeSUT()
        
        let items = [makeUniqueItem(), makeUniqueItem()]
        sut.save(items: items)
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.insertCallsCount, 1)
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

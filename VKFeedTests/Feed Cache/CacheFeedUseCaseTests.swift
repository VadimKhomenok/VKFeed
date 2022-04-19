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
    
    var insertions = [(items: [FeedItem], timestamp: Date)]()

    var deletionCompletions: [DeletionCompletion] = []
    
    func insert(items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
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
    private var currentDate: Date
    
    init(store: FeedStore = FeedStore(), currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem], completion: @escaping DeletionCompletion) {
        store.deleteCache() { [unowned self] error in
            if error == nil {
                self.store.insert(items: items, timestamp: self.currentDate)
            } else {
                completion(error)
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
        sut.save(items: items) { _ in }
        
        XCTAssertEqual(store.deleteCallsCount, 1)
    }
    
    func test_save_notInsertingItemsOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        
        let items = [makeUniqueItem(), makeUniqueItem()]
        sut.save(items: items) { _ in }
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_insertingOfItemsWithTimestampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let items = [makeUniqueItem(), makeUniqueItem()]
        
        sut.save(items: items) { _ in }
        
        store.completeDeletionWithSuccess()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    // MARK: - Helpers
    
    func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
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

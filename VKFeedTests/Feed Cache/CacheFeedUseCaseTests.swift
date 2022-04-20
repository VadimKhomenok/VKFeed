//
//  CacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.04.22.
//

import XCTest
import VKFeed

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_save_triggersCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(items: makeUniqueItems().models) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_notInsertingItemsOnCacheDeletionError() {
        let (sut, store) = makeSUT()

        sut.save(items: makeUniqueItems().models) { _ in }
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.deleteCachedFeed])
    }
    
    func test_save_insertingOfItemsWithTimestampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let items = makeUniqueItems()
        
        sut.save(items: items.models) { _ in }
        
        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.messages, [.deleteCachedFeed, .insert(items.local, timestamp)])
    }
    
    func test_save_deliversErrorOnCacheDeletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        
        expect(sut: sut, toCompleteWithError: error) {
            store.completeDeletion(with: error)
        }
    }
    
    func test_save_deliversErrorOnInsertionErrorWhileCacheDeletionSuccessful() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut: sut, toCompleteWithError: insertionError) {
            store.completeDeletionWithSuccess()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_deliversNoErrorsOnItemsInsertionSuccess() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toCompleteWithError: nil) {
            store.completeDeletionWithSuccess()
            store.completeInsertionWithSuccess()
        }
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterDeallocation() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        let deletionError = anyNSError()
        
        var capturedResults: [Error?] = []
        sut?.save(items: makeUniqueItems().models) { error in
            capturedResults.append(error)
        }
        
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterDeallocation() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        let insertionError = anyNSError()
        
        var capturedResults: [Error?] = []
        sut?.save(items: makeUniqueItems().models) { error in
            capturedResults.append(error)
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWithError error: NSError?, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let items = [makeUniqueItem(), makeUniqueItem()]
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.save(items: items) { capturedError in
            XCTAssertEqual(capturedError as NSError?, error, file: file, line: line)
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    private func makeUniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: nil, location: nil, imageUrl: anyURL())
    }
    
    private func makeUniqueItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
        let items = [makeUniqueItem(), makeUniqueItem()]
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageUrl) }
        return (items, localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
    
    private class FeedStoreSpy: FeedStore {
        enum ReceivedMessages: Equatable {
            case insert([LocalFeedItem], Date)
            case deleteCachedFeed
        }
        
        var messages = [ReceivedMessages]()
        
        var insertionCompletions: [InsertionCompletion] = []
        var deletionCompletions: [DeletionCompletion] = []
        
        func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            messages.append(.insert(items, timestamp))
            insertionCompletions.append(completion)
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
    }
}

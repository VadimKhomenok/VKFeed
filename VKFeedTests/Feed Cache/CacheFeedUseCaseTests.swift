//
//  CacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.04.22.
//

import XCTest
import VKFeed

class CacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_save_triggersCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(makeUniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_notInsertingFeedOnCacheDeletionError() {
        let (sut, store) = makeSUT()

        sut.save(makeUniqueImageFeed().models) { _ in }
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.delete])
    }
    
    func test_save_insertingOfFeedWithTimestampOnSuccessfulCacheDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: timestamp)
        let feed = makeUniqueImageFeed()
        
        sut.save(feed.models) { _ in }
        
        store.completeDeletionWithSuccess()

        XCTAssertEqual(store.messages, [.delete, .insert(feed.local, timestamp)])
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
    
    func test_save_deliversNoErrorsOnFeedInsertionSuccess() {
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
        sut?.save(makeUniqueImageFeed().models) { result in
            if case let Result.failure(error) = result { capturedResults.append(error) }
        }
        
        sut = nil
        store.completeDeletion(with: deletionError)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterDeallocation() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()
        let insertionError = anyNSError()
        
        var capturedResults: [Error?] = []
        sut?.save(makeUniqueImageFeed().models) { result in
            if case let Result.failure(error) = result { capturedResults.append(error) }
        }
        
        store.completeDeletionWithSuccess()
        sut = nil
        store.completeInsertion(with: insertionError)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWithError error: NSError?, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let feed = [makeUniqueImage(), makeUniqueImage()]
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.save(feed) { capturedResult in
            var capturedError: Error?
            if case let Result.failure(receivedError) = capturedResult { capturedError = receivedError }
            XCTAssertEqual(capturedError as NSError?, error, file: file, line: line)
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 0.5)
    }
}

//
//  ValidateCacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.04.22.
//

import XCTest
import VKFeed

class ValidateCacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_validateCache_sendsRetrieveMessageToStore() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        
        sut.validateCache() { _ in }
        store.completeRetrieval(with: retrieveError)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_doesNotDeleteCacheOnRetrieveEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheAtExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let atExpirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()

        sut.validateCache() { _ in }
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: atExpirationTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_deletesCacheOnRetrieveExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let expiredCacheTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)

        sut.validateCache() { _ in }
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: expiredCacheTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_doesNotDeleteCacheOnRetrieveNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)

        sut.validateCache() { _ in }
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTDeallocation() {
        let retrievalError = anyNSError()
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT()

        sut?.validateCache() { _ in }
        sut = nil
        store.completeRetrieval(with: retrievalError)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(fixedCurrentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: { fixedCurrentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
}

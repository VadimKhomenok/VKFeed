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
        
        sut.validateCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        
        sut.validateCache()
        store.completeRetrieval(with: retrieveError)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_doesNotDeleteCacheOnRetrieveEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheWithSevenDaysAge() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)

        sut.validateCache()
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_deletesCacheOnRetrieveWithMoreThanSevenDaysAgeCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        sut.validateCache()
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve, .delete])
    }
    
    func test_validateCache_doesNotDeleteCacheOnRetrieveWithLessThanSevenDaysAgeCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.validateCache()
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(fixedCurrentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: fixedCurrentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func makeUniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func makeUniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [makeUniqueImage(), makeUniqueImage()]
        let localFeed = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (feed, localFeed)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
}

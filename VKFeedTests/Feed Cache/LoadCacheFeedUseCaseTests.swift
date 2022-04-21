//
//  LoadCacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 20.04.22.
//

import XCTest
import VKFeed

class LoadCacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages.count, 0)
    }
    
    func test_load_sendsRetrieveMessage() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_deliversErrorOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = anyNSError()
        
        expect(sut: sut, toCompleteWithResult: .failure(retrieveError)) {
            store.completeRetrieval(with: retrieveError)
        }
    }
    
    func test_load_deliversEmptyFeedOnRetrieveEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toCompleteWithResult: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }

    func test_load_deliversFeedOnRetrieveCacheWithLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        let feed = makeUniqueImageFeed()
        expect(sut: sut, toCompleteWithResult: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversEmptyOnRetrieveCacheWithSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)

        let feed = makeUniqueImageFeed()
        expect(sut: sut, toCompleteWithResult: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversEmptyOnRetrieveCacheWithMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        let feed = makeUniqueImageFeed()
        expect(sut: sut, toCompleteWithResult: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
        }
    }

    func test_load_hasNoSideEffectsOnRetrieveError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        sut.load { _ in }
        store.completeRetrieval(with: retrievalError)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnRetrieveEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnRetrieveWithCacheAgeLessThanSevenDays() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        sut.load(completion: { _ in })
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_noSideEffectsOnRetrieveWithSevenDaysAgeCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)

        sut.load(completion: { _ in })
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_noSideEffectsOnRetrieveWithMoreThanSevenDaysAgeCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)

        sut.load(completion: { _ in })
        let feed = makeUniqueImageFeed()
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultOnDeallocation() {
        var (sut, store): (LocalFeedLoader?, FeedStoreSpy) = makeSUT(fixedCurrentDate: Date())
        
        var retrievedResult = [LocalFeedLoader.LoadResult]()
        sut?.load { result in
            retrievedResult.append(result)
        }
        
        sut = nil

        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(retrievedResult.isEmpty)
    }

    // MARK: - Helpers
    
    private func makeSUT(fixedCurrentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: fixedCurrentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWithResult expectedResult: FeedLoaderResult, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError?, expectedError as NSError?, file: file, line: line)
            default:
                XCTFail("Expected empty feed, received failure instead \(result)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func makeUniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func makeUniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [makeUniqueImage(), makeUniqueImage()]
        let localFeed = feed.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        return (feed, localFeed)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
}

extension Date {
    func adding(days: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

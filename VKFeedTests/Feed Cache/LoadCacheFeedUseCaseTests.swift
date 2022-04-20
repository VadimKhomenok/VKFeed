//
//  LoadCacheFeedUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 20.04.22.
//

import XCTest
import VKFeed

class LoadCacheFeedUseCaseTests: XCTestCase {
    func test_init_doesNotLoadOnCreation() {
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

    func test_load_deliversFeedOnRetrieveCacheWithinValidExpirePeriod() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(fixedCurrentDate: fixedCurrentDate)
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)

        let feed = makeUniqueImageFeed()
        expect(sut: sut, toCompleteWithResult: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(fixedCurrentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: fixedCurrentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWithResult expectedResult: FeedLoaderResult, onAction action: () -> Void) {
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed)
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError?, expectedError as NSError?)
            default:
                XCTFail("Expected empty feed, received failure instead \(result)")
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

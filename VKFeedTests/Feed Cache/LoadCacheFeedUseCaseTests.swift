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
        
        var retrievedError: Error?
        sut.load { error in
            retrievedError = error
        }
        
        store.completeRetrieval(with: retrieveError)
        XCTAssertEqual(retrievedError as NSError?, retrieveError)
    }
    
    func test_load_deliversEmptyFeedOnRetrieveEmptyCache() {
        let (sut, store) = makeSUT()

        var retrievedFeed: [LocalFeedImage]?
        sut.load { error in
            if error == nil {
                retrievedFeed = []
            }
        }
        
        store.completeRetrievalWithSuccess()
        
        XCTAssertEqual(retrievedFeed?.count, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
}

//
//  XCTestCase+FeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the insertion to execute")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { error in
            insertionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func delete(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the deletion to complete")
        
        var deletionError: Error?
        sut.deleteCache { error in
            deletionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.retrieve() { result in
            switch (result, expectedResult) {
            case let (.found(feed, timestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
                
            case (.empty, .empty), (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), received \(result)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

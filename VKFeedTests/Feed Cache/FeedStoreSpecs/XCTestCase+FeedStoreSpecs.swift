//
//  XCTestCase+FeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertsThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func asstertsThatRetrieveDoesNotCauseSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }
    
    func assertsThatRetrieveDeliversDataOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertsThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieveTwice: .success(CachedFeed(feed: feed.local, timestamp: timestamp)), file: file, line: line)
    }
    
    func assertsThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert((feed.local, timestamp), to: sut, file: file, line: line)
        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorWhenOverrideNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstFeed = makeUniqueImageFeed().local
        let firstTimestamp = Date()
        
        insert((feed: firstFeed, timestamp: firstTimestamp), to: sut, file: file, line: line)
        
        let latestFeed = makeUniqueImageFeed().local
        let latestTimestamp = Date()
        
        let secondInsertError = insert((feed: latestFeed, timestamp: latestTimestamp), to: sut, file: file, line: line)
        XCTAssertNil(secondInsertError, "Expected to override cache successfully", file: file, line: line)
    }
    
    func assertsThatInsertOverridesNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let firstFeed = makeUniqueImageFeed().local
        let firstTimestamp = Date()
        
        insert((feed: firstFeed, timestamp: firstTimestamp), to: sut, file: file, line: line)
        
        let latestFeed = makeUniqueImageFeed().local
        let latestTimestamp = Date()
        
        insert((feed: latestFeed, timestamp: latestTimestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
    }
    
    func assertsThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = delete(sut, file: file, line: line)
        XCTAssertNil(deletionError, "Expected to finish with no errors", file: file, line: line)
    }
    
    func assertsThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertsThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut, file: file, line: line)
        
        let deletionError = delete(sut, file: file, line: line)
        XCTAssertNil(deletionError, "Expected to finish with no errors", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut, file: file, line: line)
        delete(sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
    
    func assertsThatStoreSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        var completedOperationsInOrder = [XCTestExpectation]()
        let op1 = expectation(description: "Wait for insert to complete")
        sut.insert(feed, timestamp: timestamp) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for delete to complete")
        sut.deleteCache() { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Wait for insert to complete")
        sut.insert(feed, timestamp: timestamp) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 2.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effect operations to run serially, but operations finished in the wrong order", file: file, line: line)
    }
}

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the insertion to execute")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error}
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return insertionError
    }
    
    @discardableResult
    func delete(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the deletion to complete")
        
        var deletionError: Error?
        sut.deleteCache { result in
            if case let Result.failure(error) = result { deletionError = error }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.retrieve() { result in
            switch (result, expectedResult) {
            case let (.success(.some(retrieved)), .success(.some(expected))):
                XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
                
            case (.success(.none), .success(.none)), (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), received \(result)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

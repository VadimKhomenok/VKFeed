//
//  XCTestCase+FeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertsThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore) {
        expect(sut, toRetrieve: .empty)
    }
    
    func asstertsThatRetrieveDoesNotCauseSideEffectsOnEmptyCache(on sut: FeedStore) {
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func assertsThatRetrieveDeliversDataOnNonEmptyCache(on sut: FeedStore) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func assertsThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore) {
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        insert((feed.local, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: feed.local, timestamp: timestamp))
    }
    
    func assertsThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert((feed.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func assertThatInsertDeliversNoErrorWhenOverrideNonEmptyCache(on sut: FeedStore) {
        let firstFeed = makeUniqueImageFeed().local
        let firstTimestamp = Date()
        
        insert((feed: firstFeed, timestamp: firstTimestamp), to: sut)
        
        let latestFeed = makeUniqueImageFeed().local
        let latestTimestamp = Date()
        
        let secondInsertError = insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
        XCTAssertNil(secondInsertError, "Expected to override cache successfully")
    }
    
    func assertsThatInsertOverridesNonEmptyCache(on sut: FeedStore) {
        let firstFeed = makeUniqueImageFeed().local
        let firstTimestamp = Date()
        
        insert((feed: firstFeed, timestamp: firstTimestamp), to: sut)
        
        let latestFeed = makeUniqueImageFeed().local
        let latestTimestamp = Date()
        
        insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func assertsThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore) {
        let deletionError = delete(sut)
        XCTAssertNil(deletionError, "Expected to finish with no errors")
    }
    
    func assertsThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore) {
        delete(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertsThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        
        let deletionError = delete(sut)
        XCTAssertNil(deletionError, "Expected to finish with no errors")
    }
    
    func assertsThatDeleteOnNonEmptyCacheHasNoSideEffects(on sut: FeedStore) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed: feed, timestamp: timestamp), to: sut)
        delete(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertsThatStoreSideEffectsRunSerially(on sut: FeedStore) {
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
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effect operations to run serially, but operations finished in the wrong order")
    }
}

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

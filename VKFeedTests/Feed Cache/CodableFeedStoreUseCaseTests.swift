//
//  CodableFeedStoreUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.04.22.
//

import XCTest
import VKFeed

class CodableFeedStoreUseCaseTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_noSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert((feed.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }
    
    func test_retrieve_deliversDataOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert((feed.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        
        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: timestamp))
    }
    
    func test_retrieve_noSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert((feed.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
        
        expect(sut, toRetrieveTwice: .found(feed: feed.local, timestamp: timestamp))
    }
    
    func test_retrieve_deliversErrorWhenInvalidDataInNonEmptyCache() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        let error = anyNSError()
        
        try! Data("Invalid data".utf8).write(to: storeURL)
        
        expect(sut, toRetrieve: .failure(error))
    }
    
    func test_retrieve_noSideEffectsOnInvalidDataInNonEmptyCache() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        let error = anyNSError()
        
        try! Data("Invalid data".utf8).write(to: storeURL)
        
        expect(sut, toRetrieveTwice: .failure(error))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let firstFeed = makeUniqueImageFeed().local
        let firstTimestamp = Date()

        let firstInsertError = insert((feed: firstFeed, timestamp: firstTimestamp), to: sut)
        XCTAssertNil(firstInsertError, "Expected to insert cache successfully")
        
        let latestFeed = makeUniqueImageFeed().local
        let latestTimestamp = Date()
        
        let secondInsertError = insert((feed: latestFeed, timestamp: latestTimestamp), to: sut)
        XCTAssertNil(secondInsertError, "Expected to override cache successfully")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionFailureAndValuesAreNotSavedInCache() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected an error, received no error")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_noDeliveryOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = delete(sut)
        XCTAssertNil(deletionError, "Expected to finish with no errors")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptyCacheAfterDeleteCachedData() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed: feed, timestamp: timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert without errors")
        
        let deletionError = delete(sut)
        XCTAssertNil(deletionError, "Expected to finish with no errors")
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorWhenDeletionFailed() {
        let deniedAccessStoreURL = cachesDirectory()
        let sut = makeSUT(storeURL: deniedAccessStoreURL)

        let deletionError = delete(sut)
        XCTAssertNotNil(deletionError, "Expected delete to fail with error")

        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the insertion to execute")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { error in
            insertionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return insertionError
    }
    
    private func delete(_ sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the deletion to complete")
        
        var deletionError: Error?
        sut.deleteCache { error in
            deletionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
        
        return deletionError
    }
    
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}

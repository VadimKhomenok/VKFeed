//
//  CodableFeedStoreUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.04.22.
//

import XCTest
import VKFeed

class CodableFeedStore {
    private struct Cache: Codable {
        var feed: [CodableFeedImage]
        var timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private var id: UUID
        private var description: String?
        private var location: String?
        private var url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private var storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let cacheData = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }

        do {
            let cache = try JSONDecoder().decode(Cache.self, from: cacheData)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
            let data = try JSONEncoder().encode(cache)
            try data.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(_ completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            completion(nil)
            return
        }
            
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

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
    
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the insertion to execute")
        
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { error in
            insertionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return insertionError
    }
    
    private func delete(_ sut: CodableFeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let expectation = expectation(description: "Wait for the deletion to complete")
        
        var deletionError: Error?
        sut.delete { error in
            deletionError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
        
        return deletionError
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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

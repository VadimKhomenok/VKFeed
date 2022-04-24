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

        let cache = try! JSONDecoder().decode(Cache.self, from: cacheData)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let data = try! JSONEncoder().encode(cache)
        try! data.write(to: storeURL)
        completion(nil)
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
        
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.insert(feed.local, timestamp: fixedCurrentDate) { error in
            if let error = error {
                XCTFail("Expected no errors, but received error instead \(error)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_retrieve_deliversDataOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let expectation = expectation(description: "Wait for the completion to execute")
        
        sut.insert(feed.local, timestamp: fixedCurrentDate) { error in
            XCTAssertNil(error, "Expected to insert feed without errors")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        
        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: fixedCurrentDate))
    }
    
    func test_retrieve_noSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = makeUniqueImageFeed()
        let fixedCurrentDate = Date()
        
        let expectation = expectation(description: "Wait for the completion to execute")
        
        sut.insert(feed.local, timestamp: fixedCurrentDate) { error in
            XCTAssertNil(error, "Expected to insert feed without errors")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        
        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: fixedCurrentDate))
        expect(sut, toRetrieve: .found(feed: feed.local, timestamp: fixedCurrentDate))
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.retrieve() { result in
            switch (result, expectedResult) {
            case let (.found(feed, timestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
                
            case (.empty, .empty):
                break
                
            default:
                XCTFail("Expected \(expectedResult), received \(result)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
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

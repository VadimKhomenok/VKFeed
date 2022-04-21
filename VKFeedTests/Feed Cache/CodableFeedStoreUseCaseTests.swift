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
        var feed: [LocalFeedImage]
        var timestamp: Date
    }

    private var cachedFeedPathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let cacheData = try? Data(contentsOf: cachedFeedPathURL) else {
            completion(.empty)
            return
        }

        let cache = try! JSONDecoder().decode(Cache.self, from: cacheData)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let data = try! JSONEncoder().encode(Cache(feed: feed, timestamp: timestamp))
        try! data.write(to: cachedFeedPathURL)
        completion(nil)
    }
}

class CodableFeedStoreUseCaseTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store"))
    }
    
    override func tearDown() {
        super.tearDown()

        try? FileManager.default.removeItem(at: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store"))
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.retrieve() { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty, but received \(result)")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_retrieve_noSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "Wait for the completion to execute")
        sut.retrieve() { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty, but received \(firstResult) and \(secondResult)")
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
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
            
            sut.retrieve() { result in
                switch result {
                case let .found(receivedFeed, receivedTimestamp):
                    XCTAssertEqual(receivedFeed, feed.local)
                    XCTAssertEqual(receivedTimestamp, fixedCurrentDate)
                default:
                    XCTFail("Expected to found feed, but received \(result)")
                }
                
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

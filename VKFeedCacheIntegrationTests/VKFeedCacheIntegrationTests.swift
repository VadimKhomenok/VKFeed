//
//  VKFeedCacheIntegrationTests.swift
//  VKFeedCacheIntegrationTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import XCTest
import VKFeed

class VKFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnSeparateInstances() {
        let sutForSave = makeSUT()
        let sutForLoad = makeSUT()
        let feed = makeUniqueImageFeed().models
        
        save(feed, with: sutForSave)
        
        expect(sutForLoad, toLoad: feed)
    }
    
    func test_save_overridesCacheSavedOnSeparateInstances() {
        let firstSaveSut = makeSUT()
        let secondSaveSut = makeSUT()
        let sutForLoad = makeSUT()
        let firstFeed = makeUniqueImageFeed().models
        let latestFeed = makeUniqueImageFeed().models
        
        save(firstFeed, with: firstSaveSut)
        save(latestFeed, with: secondSaveSut)

        expect(sutForLoad, toLoad: latestFeed)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date())
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for save to complete")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, "Expected to save without errors", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load to complete")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
                
            case let .failure(error):
                XCTFail("Expected success with feed, received failure with \(error) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificStoreURL() -> URL {
        cachesDirectory().appendingPathComponent("\(type(of: self)).store")
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

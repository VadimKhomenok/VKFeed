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
        
        let expectation = expectation(description: "Wait for load to complete")
        sut.load { result in
            switch result {
            case let .success(feed):
                XCTAssertTrue(feed.isEmpty)
            default:
                XCTFail("Expected success with no items, received \(result) instead")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnSeparateInstances() {
        let firstSut = makeSUT()
        let feed = makeUniqueImageFeed()
        
        let exp1 = expectation(description: "Wait for save to complete")
        firstSut.save(feed.models) { error in
            XCTAssertNil(error, "Expected to save without errors")
            exp1.fulfill()
        }
        
        wait(for: [exp1], timeout: 1.0)
        
        let secondSut = makeSUT()
        let exp2 = expectation(description: "Wait for save to complete")
        secondSut.load { result in
            switch result {
            case let .success(cachedFeed):
                XCTAssertEqual(cachedFeed, feed.models)
            case let .failure(error):
                XCTFail("Expected success with feed items, received \(error) instead")
            }
            
            exp2.fulfill()
        }
        
        wait(for: [exp2], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date())
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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

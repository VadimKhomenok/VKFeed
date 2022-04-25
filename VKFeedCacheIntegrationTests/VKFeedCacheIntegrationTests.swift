//
//  VKFeedCacheIntegrationTests.swift
//  VKFeedCacheIntegrationTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import XCTest
import VKFeed

class VKFeedCacheIntegrationTests: XCTestCase {
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let expectation = expectation(description: "Wait for the load to complete")
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
}

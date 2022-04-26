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
        
        expect(sut, toLoadWithResult: .success([]))
    }
    
    func test_load_deliversItemsSavedOnSeparateInstances() {
        let sutForSave = makeSUT()
        let feed = makeUniqueImageFeed()
        
        let saveExpectation = expectation(description: "Wait for save to complete")
        sutForSave.save(feed.models) { error in
            XCTAssertNil(error, "Expected to save without errors")
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        let sutForLoad = makeSUT()
        expect(sutForLoad, toLoadWithResult: .success(feed.models))
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
    
    private func expect(_ sut: LocalFeedLoader, toLoadWithResult expectedResult: LocalFeedLoader.LoadResult, file: StaticString = #file, line: UInt = #line) {
        let expectation = expectation(description: "Wait for load to complete")
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(feed), .success(expectedFeed)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
                
            case let (.failure(error), .failure(expectedError)):
                XCTAssertEqual(error as NSError?, expectedError as NSError?, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult), received \(result) instead", file: file, line: line)
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

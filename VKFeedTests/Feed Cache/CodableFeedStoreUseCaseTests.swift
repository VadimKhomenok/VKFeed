//
//  CodableFeedStoreUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.04.22.
//

import XCTest
import VKFeed

class CodableFeedStoreUseCaseTests: XCTestCase, FailableFeedStoreSpecs {
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
        
        assertsThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        asstertsThatRetrieveDoesNotCauseSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversDataOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertsThatRetrieveDeliversDataOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertsThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversErrorWhenInvalidDataInNonEmptyCache() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! Data("Invalid data".utf8).write(to: storeURL)
        
        assertsThatRetrieveDeliversErrorWhenInvalidDataInNonEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectsOnInvalidDataInNonEmptyCache() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! Data("Invalid data".utf8).write(to: storeURL)
        
        assertsThatRetrieveHasNoSideEffectsOnInvalidDataInNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        assertsThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorWhenOverrideNonEmptyCache() {
        let sut = makeSUT()

        assertThatInsertDeliversNoErrorWhenOverrideNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesNonEmptyCache() {
        let sut = makeSUT()
        
        assertsThatInsertOverridesNonEmptyCache(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionFailure() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertsThatInsertDeliversErrorOnInsertionFailure(on: sut)
    }
    
    func test_insert_noSideEffectsOnInsertionFailure() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertsThatInsertHasNoSideEffectsOnInsertionFailure(on: sut)
    }
    
    func test_delete_noErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertsThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_noSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertsThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_noErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertsThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptyCacheAfterDeleteCachedData() {
        let sut = makeSUT()
        
        assertsThatDeleteOnNonEmptyCacheHasNoSideEffects(on: sut)
    }
    
    func test_delete_deliversErrorWhenDeletionFailed() {
//        let deniedAccessStoreURL = cachesDirectory()
//        let sut = makeSUT(storeURL: deniedAccessStoreURL)
//
//        let deletionError = delete(sut)
//        XCTAssertNotNil(deletionError, "Expected delete to fail with error")
    }
    
    func test_delete_noSideEffectsOnDeletionFailed() {
//        let deniedAccessStoreURL = cachesDirectory()
//        let sut = makeSUT(storeURL: deniedAccessStoreURL)
//
//        delete(sut)
//
//        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        
        assertsThatStoreSideEffectsRunSerially(on: sut)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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

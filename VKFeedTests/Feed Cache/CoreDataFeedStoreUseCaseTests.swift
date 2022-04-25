//
//  CoreDataFeedStoreUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import XCTest
import VKFeed

class CoreDataFeedStoreUseCaseTests: XCTestCase, FeedStoreSpecs {
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
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        
        return sut
    }
}

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
        let sut = CoreDataFeedStore()
        assertsThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_noSideEffectsOnEmptyCache() {
        let sut = CoreDataFeedStore()
        asstertsThatRetrieveDoesNotCauseSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversDataOnNonEmptyCache() {
        
    }
    
    func test_retrieve_noSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorWhenOverrideNonEmptyCache() {
        
    }
    
    func test_insert_overridesNonEmptyCache() {
        
    }
    
    func test_delete_noErrorOnEmptyCache() {
        
    }
    
    func test_delete_noSideEffectsOnEmptyCache() {
        
    }
    
    func test_delete_noErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptyCacheAfterDeleteCachedData() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
    }
}

//
//  FeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_noSideEffectsOnEmptyCache()
    func test_retrieve_deliversDataOnNonEmptyCache()
    func test_retrieve_noSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorWhenOverrideNonEmptyCache()
    func test_insert_overridesNonEmptyCache()
    
    func test_delete_noErrorsOnEmptyCache()
    func test_delete_noSideEffectsOnEmptyCache()
    func test_delete_noErrorOnNonEmptyCache()
    func test_delete_emptyCacheAfterDeleteCachedData()
    
    func test_storeSideEffects_runSerially()
}

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorWhenInvalidDataInNonEmptyCache()
    func test_retrieve_noSideEffectsOnInvalidDataInNonEmptyCache()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionFailure()
    func test_insert_noSideEffectsOnInsertionFailure()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorWhenDeletionFailed()
    func test_delete_noSideEffectsOnDeletionFailed()
}

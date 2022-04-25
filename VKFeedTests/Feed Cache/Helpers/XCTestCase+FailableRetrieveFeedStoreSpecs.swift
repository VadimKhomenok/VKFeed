//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertsThatRetrieveDeliversErrorWhenInvalidDataInNonEmptyCache(on sut: FeedStore) {
        let error = anyNSError()

        expect(sut, toRetrieve: .failure(error))
    }
    
    func assertsThatRetrieveHasNoSideEffectsOnInvalidDataInNonEmptyCache(on sut: FeedStore) {
        let error = anyNSError()
        
        expect(sut, toRetrieveTwice: .failure(error))
    }
}

//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FeedStoreSpecs where Self: XCTestCase {
    func assertsThatRetrieveDeliversErrorWhenInvalidDataInNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = anyNSError()

        expect(sut, toRetrieve: .failure(error), file: file, line: line)
    }
    
    func assertsThatRetrieveHasNoSideEffectsOnInvalidDataInNonEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let error = anyNSError()
        
        expect(sut, toRetrieveTwice: .failure(error), file: file, line: line)
    }
}

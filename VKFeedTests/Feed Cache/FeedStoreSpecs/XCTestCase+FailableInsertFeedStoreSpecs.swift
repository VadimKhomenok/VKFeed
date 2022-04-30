//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertsThatInsertDeliversErrorOnInsertionFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut, file: file, line: line)
        XCTAssertNotNil(insertionError, "Expected an error, received no error", file: file, line: line)
    }
    
    func assertsThatInsertHasNoSideEffectsOnInsertionFailure(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = makeUniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}

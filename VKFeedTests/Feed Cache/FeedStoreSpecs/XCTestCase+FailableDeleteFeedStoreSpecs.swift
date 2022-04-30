//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.04.22.
//

import VKFeed
import XCTest

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertsThatDeleteDeliversErrorWhenDeletionFailed(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = delete(sut, file: file, line: line)
        XCTAssertNotNil(deletionError, "Expected delete to fail with error", file: file, line: line)
    }
    
    func assertsThatDeleteHasNoSideEffectsOnDeletionFailed(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        delete(sut, file: file, line: line)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}

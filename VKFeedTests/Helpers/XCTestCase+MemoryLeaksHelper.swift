//
//  XCTestCase+MemoryLeaksHelper.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 14.04.22.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is not deallocated, possible memory leak.", file: file, line: line)
        }
    }
}

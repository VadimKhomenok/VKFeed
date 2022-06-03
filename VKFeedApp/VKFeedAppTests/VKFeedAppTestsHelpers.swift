//
//  VKFeedAppTestsHelpers.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 3.06.22.
//

import XCTest
import VKFeed

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is not deallocated, possible memory leak.", file: file, line: line)
        }
    }
}

func anyNSError() -> NSError {
    return NSError(domain: "An error", code: 400)
}

func anyURL() -> URL {
    return URL(string: "http://api-url.com")!
}

func makeUniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: nil, location: nil, url: anyURL()),
            FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())]
}

//
//  FeedEndpointTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 1.07.22.
//

import XCTest
import VKFeed

class FeedEndpointTests: XCTestCase {
    
    func test_feed_endpointURL() {
        let baseUrl = URL(string: "http://base-url.com")!
        
        let resultUrl = FeedEndpoint.get.url(baseUrl: baseUrl)
        let expectedUrl = URL(string: "http://base-url.com/v1/feed")!
        
        XCTAssertEqual(resultUrl, expectedUrl)
    }
}

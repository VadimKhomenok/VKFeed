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
        
        let resultUrl = FeedEndpoint.get().url(baseUrl: baseUrl)
        
        XCTAssertEqual(resultUrl.scheme, "http", "scheme")
        XCTAssertEqual(resultUrl.host, "base-url.com", "host")
        XCTAssertEqual(resultUrl.path, "/v1/feed", "path")
        XCTAssertEqual(resultUrl.query, "limit=10", "query")
    }
    
    func test_feed_endpointURLAfterImage() {
        let image = makeUniqueImage()
        let baseUrl = URL(string: "http://base-url.com")!
        
        let resultUrl = FeedEndpoint.get(after: image).url(baseUrl: baseUrl)
        
        XCTAssertEqual(resultUrl.scheme, "http", "scheme")
        XCTAssertEqual(resultUrl.host, "base-url.com", "host")
        XCTAssertEqual(resultUrl.path, "/v1/feed", "path")
        XCTAssertEqual(resultUrl.query?.contains("limit=10"), true, "limit query param")
        XCTAssertEqual(resultUrl.query?.contains("after_id=\(image.id)"), true, "after_id query param")
    }
}

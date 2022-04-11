//
//  RemoteFeedLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 11.04.22.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_requestDataFromURL() {
        let client = HTTPClient()
        client.requestedURL = URL(string: "https://api-url.com")
        let _ = RemoteFeedLoader()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

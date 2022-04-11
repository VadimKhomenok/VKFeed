//
//  RemoteFeedLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 11.04.22.
//

import XCTest

class RemoteFeedLoader {
    private var client: HTTPClient
    var url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://api-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    func makeSUT(url: URL = URL(string: "https://default-api-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientMock: HTTPClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
}

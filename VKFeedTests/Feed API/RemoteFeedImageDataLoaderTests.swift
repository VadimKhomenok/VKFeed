//
//  RemoteFeedImageDataLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed
import XCTest

class RemoteFeedImageDataLoader {
    private var client: HTTPClient?
    
    init(client: HTTPClient) {
        
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.messages.isEmpty)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: httpClient)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, httpClient)
    }
}

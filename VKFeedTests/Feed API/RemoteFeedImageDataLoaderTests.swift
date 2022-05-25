//
//  RemoteFeedImageDataLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed
import XCTest

//public protocol FeedImageDataLoaderTask {
//    func cancel()
//}
//
//public protocol FeedImageDataLoader {
//    typealias Result = Swift.Result<Data, Error>
//    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
//}

class RemoteFeedImageDataLoader {
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Error?) -> Void = { _ in }) {
        client.get(from: url, completion: { _ in
            completion(anyNSError())
        })
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.messages.isEmpty, "Expected not to send any requests on initialization")
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url)
        XCTAssertEqual(client.requestedURLs, [url], "Expected to request a URL when loadImageData called")
        
        sut.loadImageData(from: url)
        XCTAssertEqual(client.requestedURLs, [url, url], "Expected to request twice when loadImageData called twice")
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        let exp = expectation(description: "Wait for load to complete")
        sut.loadImageData(from: url) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        
        client.complete(with: anyNSError())
        
        wait(for: [exp], timeout: 1)
    }

    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: httpClient)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, httpClient)
    }
}

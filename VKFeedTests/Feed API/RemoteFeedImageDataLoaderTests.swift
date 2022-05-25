//
//  RemoteFeedImageDataLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed
import XCTest

class RemoteFeedImageDataLoader {
    private var client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            
            default:
                break
            }
        })
    }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestData() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty, "Expected not to send any requests on initialization")
    }
    
    func test_loadImageData_requestsImageDataFromURL() {
        let (sut, client) = makeSUT()
        let url = anyURL()
        
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url], "Expected to request a URL when loadImageData called")
        
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url], "Expected to request twice when loadImageData called twice")
    }
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        expect(sut: sut, toCompleteWith: .failure(error)) {
            client.complete(with: error)
        }
    }

    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, httpClient: HTTPClientSpy) {
        let httpClient = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: httpClient)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, httpClient)
    }
    
    private func expect(sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load to complete")
        
        sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(data), .success(expectedData)):
                XCTAssertEqual(data, expectedData, file: file, line: line)
                
            case let (.failure(error as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(result) instead", file: file, line: line)
            }
         
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}

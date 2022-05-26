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
    
    private struct HTTPTaskWrapper: FeedImageDataLoaderTask {
        let wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return HTTPTaskWrapper(wrapped: client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200 && !data.isEmpty {
                    completion(.success(data))
                } else {
                    completion(.failure(Error.invalidData))
                }
                
            case let .failure(error):
                completion(.failure(error))
                
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
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200StatusCodeResponse() {
        let (sut, client) = makeSUT()
        let data = "Any data".data(using: .utf8)!
        
        let codes = [199, 201, 300, 400, 500]
        codes.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: data, at: index)
            }
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200WithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()
        
        expect(sut: sut, toCompleteWith: failure(.invalidData)) {
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }
    
    func test_loadImageData_deliversReceivedNonEmptyDataOn200Success() {
        let (sut, client) = makeSUT()
        let anyData = anyData()
        
        expect(sut: sut, toCompleteWith: .success(anyData)) {
            client.complete(withStatusCode: 200, data: anyData)
        }
    }

    func test_loadImageData_doesNotDeliverAfterDeallocation() {
        var (sut, client): (RemoteFeedImageDataLoader?, HTTPClientSpy) = makeSUT()
        
        var capturedResults = [FeedImageDataLoader.Result]()
        sut!.loadImageData(from: anyURL()) { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: anyData())
        
        XCTAssertTrue(capturedResults.isEmpty, "Expected no results if sut was deallocated before client load completion")
    }
    
    
    // MARK: - Helpers
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }
    
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
                
            case let (.failure(error as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
                
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
        
        private struct Task: HTTPClientTask {
            func cancel() { }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}

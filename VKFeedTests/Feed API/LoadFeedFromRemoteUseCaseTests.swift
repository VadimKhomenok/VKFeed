//
//  RemoteFeedLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 11.04.22.
//

import XCTest
import VKFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://api-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_checkIfCanLoadMoreThanOnce() {
        let url = URL(string: "https://api-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithExpectedResult: failure(.connectivity)) {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnNon200StatusResponse() {
        let (sut, client) = makeSUT()
        
        let codes = [199, 201, 300, 400, 500]
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithExpectedResult: failure(.invalidData)) {
                let validJsonData = makeItemsJson([])
                client.complete(withStatusCode: code, data: validJsonData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200StatusCodeWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithExpectedResult: failure(.invalidData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_load_deliversNoItemsOn200StatusCodeWithEmptyJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithExpectedResult: .success([])) {
            let emptyJson = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyJson)
        }
    }
    
    func test_load_deliversFeedItemsOn200StatusCodeWithItemsJson() {
        let (sut, client) = makeSUT()
        
        let (item1, item1Json) = makeItem(id: UUID(), imageUrl: URL(string: "https://url.com")!)
        let (item2, item2Json) = makeItem(id: UUID(), description: "a description", location: "a location", imageUrl: URL(string: "https://another-url.com")!)
        
        expect(sut, toCompleteWithExpectedResult: .success([item1, item2])) {
            let itemsJsonData = makeItemsJson([item1Json, item2Json])
            client.complete(withStatusCode: 200, data: itemsJsonData)
        }
    }
    
    func test_load_notDeliverCompletionWhenDeallocated() {
        var (sut, client): (RemoteFeedLoader?, HTTPClientSpy) = makeSUT()
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://default-api-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (FeedImage, [String : Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageUrl)
        
        let itemJson = [
            "id" : item.id.uuidString,
            "description" : item.description,
            "location" : item.location,
            "image" : item.url.absoluteString
        ].compactMapValues { $0 }
        
        return (item, itemJson)
    }
    
    private func makeItemsJson(_ items: [[String : Any]]) -> Data {
        let itemsJson = [
            "items" : items
        ]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithExpectedResult expectedResult: RemoteFeedLoader.Result, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Was expecting \(expectedResult) but received \(result) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}

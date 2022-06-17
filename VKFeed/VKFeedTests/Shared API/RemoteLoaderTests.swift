//
//  RemoteLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 16.06.22.
//

import XCTest
import VKFeed

class RemoteLoaderTests: XCTestCase {
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

        expect(sut, toCompleteWithExpectedResult: failure(RemoteLoader<String>.Error.connectivity)) {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })
        
        expect(sut, toCompleteWithExpectedResult: failure(RemoteLoader<String>.Error.invalidData)) {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        }
    }
    
    func test_load_deliversMappedResource() {
        let resourceString = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })

        expect(sut, toCompleteWithExpectedResult: .success(resourceString)) {
            client.complete(withStatusCode: 200, data: Data(resourceString.utf8))
        }
    }
    
    func test_load_notDeliverCompletionWhenDeallocated() {
        var (sut, client): (RemoteLoader?, HTTPClientSpy) = makeSUT()
        
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        url: URL = URL(string: "https://default-api-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
            let client = HTTPClientSpy()
            let sut = RemoteLoader(url: url, client: client, mapper: mapper)
            
            trackForMemoryLeaks(client, file: file, line: line)
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return (sut, client)
        }
    
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
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
    
    private func expect(_ sut: RemoteLoader<String>, toCompleteWithExpectedResult expectedResult: RemoteLoader<String>.Result, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            default:
                XCTFail("Was expecting \(expectedResult) but received \(result) instead", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 16.06.22.
//

import XCTest
import VKFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
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
    
    func test_load_deliversErrorOnNon2xxStatusResponse() {
        let (sut, client) = makeSUT()
        
        let codes = [150, 199, 300, 400, 500]
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithExpectedResult: failure(.invalidData)) {
                let validJsonData = makeItemsJson([])
                client.complete(withStatusCode: code, data: validJsonData, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxStatusCodeWithInvalidJson() {
        let (sut, client) = makeSUT()
        
        let codes = [200, 201, 240, 290, 299]
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithExpectedResult: failure(.invalidData)) {
                let invalidJson = Data("invalid json".utf8)
                client.complete(withStatusCode: code, data: invalidJson, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn2xxStatusCodeWithEmptyJson() {
        let (sut, client) = makeSUT()
        
        let codes = [200, 201, 240, 290, 299]
        codes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithExpectedResult: .success([])) {
                let emptyJson = makeItemsJson([])
                client.complete(withStatusCode: code, data: emptyJson, at: index)
            }
        }
    }
    
    func test_load_deliversFeedItemsOn200StatusCodeWithItemsJson() {
        let (sut, client) = makeSUT()
        
        let (item1, item1Json) = makeItem(
            id: UUID(),
            message: "a comment",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "User 1")
        let (item2, item2Json) = makeItem(
            id: UUID(),
            message: "another comment",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "User 2")
        
        expect(sut, toCompleteWithExpectedResult: .success([item1, item2])) {
            let itemsJsonData = makeItemsJson([item1Json, item2Json])
            client.complete(withStatusCode: 200, data: itemsJsonData)
        }
    }
    
    func test_load_notDeliverCompletionWhenDeallocated() {
        var (sut, client): (RemoteImageCommentsLoader?, HTTPClientSpy) = makeSUT()
        
        var capturedResults = [RemoteImageCommentsLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://default-api-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, client)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (ImageComment, [String : Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let itemJson: [String : Any] = [
            "id" : id.uuidString,
            "message" : message,
            "created_at" : createdAt.iso8601String,
            "author" : [
                "username" : username
            ]
        ]
        
        return (item, itemJson)
    }
    
    private func makeItemsJson(_ items: [[String : Any]]) -> Data {
        let itemsJson = [
            "items" : items
        ]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
    
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithExpectedResult expectedResult: RemoteImageCommentsLoader.Result, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch (result, expectedResult) {
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            case let (.failure(error as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
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

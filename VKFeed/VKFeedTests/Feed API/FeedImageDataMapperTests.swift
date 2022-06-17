//
//  FeedImageDataMapperTests.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed
import XCTest

class FeedImageDataMapperTests: XCTestCase {
    
    func test_map_throwsInvalidDataErrorOnNon200StatusCodeResponse() throws {
        let codes = [199, 201, 300, 400, 500]
        let data = "Any data".data(using: .utf8)!
        
        try codes.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200WithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversReceivedNonEmptyDataOn200Success() throws {
        let anyData = anyData()
        
        let result = try FeedImageDataMapper.map(anyData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, anyData)
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
        
        _ = sut.loadImageData(from: url) { result in
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
}

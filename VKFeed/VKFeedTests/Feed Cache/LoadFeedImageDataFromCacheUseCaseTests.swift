//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 30.05.22.
//

import Foundation
import XCTest
import VKFeed

class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_localFeedImageDataLoader_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadStoredData_requestsStoredDataForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(dataFor: url)])
    }
    
    func test_loadImageDataFromURL_failsOnStoreError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            let retrievalError = anyNSError()
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: notFound()) {
            store.completeRetrieval(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataWhenFindsImageDataForURL() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            store.completeRetrieval(with: imageData)
        }
    }
    
    
    // MARK: - Helpers
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.LoadError.notFound)
    }
    
    private func never(file: StaticString = #file, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load to complete")
        
        action()
        
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure(let receivedError as LocalFeedImageDataLoader.LoadError),
                  .failure(let expectedError as LocalFeedImageDataLoader.LoadError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

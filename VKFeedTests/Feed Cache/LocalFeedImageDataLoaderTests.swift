//
//  LocalFeedImageDataLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 30.05.22.
//

import Foundation
import XCTest
import VKFeed

class LocalFeedImageDataLoaderTests: XCTestCase {
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
            store.complete(with: retrievalError)
        }
    }
    
    func test_loadImageDataFromURL_deliversNotFoundErrorOnNotFound() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }
    
    func test_loadImageDataFromURL_deliversStoredDataWhenFindsImageDataForURL() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut, toCompleteWith: .success(imageData)) {
            store.complete(with: imageData)
        }
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()
        
        store.complete(with: imageData)
        store.complete(with: anyNSError())
        store.complete(with: .none)
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterInstanceWasDeallocated() {
        var (sut, store): (FeedImageDataLoader?, StoreSpy) = makeSUT()
        let imageData = anyData()
        
        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { received.append($0) }
        
        sut = nil
        
        store.complete(with: imageData)
        
        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        let data = anyData()
        
        sut.save(data: data, for: url, completion: { _ in })
        
        XCTAssertEqual(store.messages, [.insert(data: data, for: url)])
    }
    
    // MARK: - Helpers
    
    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }
    
    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }
    
    private func never(file: StaticString = #file, line: UInt = #line) {
        XCTFail("Expected no no invocations", file: file, line: line)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "Wait for load to complete")
        
        _ = sut.loadImageData(from: url) { result in
            switch (result, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case (.failure(let receivedError as LocalFeedImageDataLoader.Error),
                  .failure(let expectedError as LocalFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class StoreSpy: FeedImageDataStore {
        
        enum ReceivedMessages: Equatable {
            case retrieve(dataFor: URL)
            case insert(data: Data, for: URL)
        }
        
        private(set) var messages = [ReceivedMessages]()
        private(set) var completions = [(FeedImageDataStore.Result) -> Void]()
    
        func insert(_ imageData: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
            messages.append(.insert(data: imageData, for: url))
        }
        
        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
            messages.append(.retrieve(dataFor: url))
            completions.append(completion)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func complete(with data: Data?, at index: Int = 0) {
            completions[index](.success(data))
        }
    }
}

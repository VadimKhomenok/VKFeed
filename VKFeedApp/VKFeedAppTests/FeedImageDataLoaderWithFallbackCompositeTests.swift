//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import XCTest
import Foundation
import VKFeed
import VKFeedApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primarySpy, fallbackSpy) = makeSUT()
        
        XCTAssertTrue(primarySpy.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadFeedImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(primarySpy.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackSpy.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadFeedImageData_loadsFromFallbackLoaderOnPrimaryLoaderFailure() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        primarySpy.complete(with: anyNSError())

        XCTAssertEqual(primarySpy.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertEqual(fallbackSpy.loadedURLs, [url], "Expected to load URL from fallback loader")
    }
    
    func test_loadFeedImageData_cancelsPrimaryTaskOnCancel() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()

        XCTAssertEqual(primarySpy.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertEqual(fallbackSpy.cancelledURLs, [], "Expected no cancelled URLs in the fallback loader")
    }
    
    func test_loadFeedImageData_cancelsFallbackTaskOnCancelAfterPrimaryLoaderFailure() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        primarySpy.complete(with: anyNSError())
        task.cancel()

        XCTAssertEqual(primarySpy.cancelledURLs, [], "Expected no cancelled URLs in the primary loader")
        XCTAssertEqual(fallbackSpy.cancelledURLs, [url], "Expected to cancel URL loading from fallback loader")
    }
    
    func test_loadFeedImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primarySpy, _) = makeSUT()
        let primaryData = anyData()
    
        expect(sut, toCompleteWith: .success(primaryData)) {
            primarySpy.complete(with: primaryData)
        }
    }
    
    func test_loadFeedImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
        let fallbackData = anyData()
    
        expect(sut, toCompleteWith: .success(fallbackData)) {
            primarySpy.complete(with: anyNSError())
            fallbackSpy.complete(with: fallbackData)
        }
    }
    
    func test_loadFeedImageData_deliversErrorOnBothLoadersFailed() {
        let (sut, primarySpy, fallbackSpy) = makeSUT()
    
        expect(sut, toCompleteWith: .failure(anyNSError())) {
            primarySpy.complete(with: anyNSError())
            fallbackSpy.complete(with: anyNSError())
        }
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        let primarySpy = FeedImageDataLoaderSpy()
        let fallbackSpy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primarySpy, fallback: fallbackSpy)
        
        trackForMemoryLeaks(primarySpy, file: file, line: line)
        trackForMemoryLeaks(fallbackSpy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, primarySpy, fallbackSpy)
    }
    
    func expect(_ sut: FeedImageDataLoaderWithFallbackComposite, toCompleteWith expectedResult: FeedImageDataLoader.Result, onAction action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: anyURL()) { result in
            switch (result, expectedResult) {
            case let (.success(resultData), .success(expectedData)):
                XCTAssertEqual(resultData, expectedData, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(result) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedImageDataLoaderSpy: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            var cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private(set) var cancelledURLs = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}

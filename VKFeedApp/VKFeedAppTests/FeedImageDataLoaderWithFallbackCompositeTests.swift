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

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    
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
}

//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation
import XCTest
import VKFeed
import VKFeedApp

protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            completion(result.map { data in
                self?.cache.save(data, for: url) { _ in }
                return data
            })
        }
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, spy) = makeSUT()
        
        XCTAssertTrue(spy.loadedURLs.isEmpty, "Expected no loaded URLs")
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(spy.loadedURLs, [url], "Expected to load URL from loader")
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(spy.cancelledURLs, [url], "Expected to cancel URL loading from loader")
    }
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let expectedData = anyData()
        let (sut, spy) = makeSUT()
        
        expect(sut, toCompleteWith: .success(expectedData), onAction: {
            spy.complete(with: expectedData)
        })
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let (sut, spy) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), onAction: {
            spy.complete(with: anyNSError())
        })
    }

    func test_loadImageData_cachesLoadedDataOnLoaderSuccess() {
        let url = anyURL()
        let expectedData = anyData()
        let cacheSpy = FeedImageDataCacheSpy()
        let (sut, spy) = makeSUT(cache: cacheSpy)
        
        _ = sut.loadImageData(from: url) { _ in }
        spy.complete(with: expectedData)
        
        XCTAssertEqual(cacheSpy.messages, [.save(data: expectedData, url: url)], "Expected to cache loaded image data on success")
    }
    
    func test_loadImageData_doesNotCacheDataOnLoaderFailure() {
        let cacheSpy = FeedImageDataCacheSpy()
        let (sut, spy) = makeSUT(cache: cacheSpy)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        spy.complete(with: anyNSError())
        
        XCTAssertTrue(cacheSpy.messages.isEmpty, "Expected not to cache image data on load error")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(cache: FeedImageDataCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, spy: FeedImageDataLoaderSpy) {
        let spy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: spy, cache: cache)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
    }
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(data: Data, url: URL)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data: data, url: url))
            completion(.success(()))
        }
    }
}

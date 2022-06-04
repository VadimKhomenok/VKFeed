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
            if let data = try? result.get() {
                self?.cache.save(data, for: url, completion: { _ in })
            }
            
            completion(result)
        }
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
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

    func test_load_saveCacheOnLoaderSuccess() {
        let expectedData = anyData()
        let cacheSpy = FeedImageDataCacheSpy()
        let (sut, spy) = makeSUT(cache: cacheSpy)
        
        expect(sut, toCompleteWith: .success(expectedData), onAction: {
            spy.complete(with: expectedData)
        })
        
        XCTAssertEqual(cacheSpy.messages, [.save(expectedData)])
    }
    
    func test_load_doesNotSaveCacheOnLoaderFailure() {
        let cacheSpy = FeedImageDataCacheSpy()
        let (sut, spy) = makeSUT(cache: cacheSpy)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        spy.complete(with: anyNSError())
        
        XCTAssertEqual(cacheSpy.messages, [])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(cache: FeedImageDataCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoaderCacheDecorator, spy: FeedImageDataLoaderSpy) {
        let spy = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: spy, cache: cache)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, spy)
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
    
    private class FeedImageDataCacheSpy: FeedImageDataCache {
        enum Message: Equatable {
            case save(Data)
        }
        
        private(set) var messages = [Message]()
        
        func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data))
            completion(.success(()))
        }
    }
}

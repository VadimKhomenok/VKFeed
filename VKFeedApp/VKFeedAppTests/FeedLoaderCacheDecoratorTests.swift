//
//  FeedLoaderCacheDecoratorTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation
import XCTest
import VKFeed
import VKFeedApp

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let expectedFeed = makeUniqueFeed()
        let sut = makeSUT(with: .success(expectedFeed))
        
        expect(sut, toCompleteWith: .success(expectedFeed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(with: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_savesCacheOnLoaderSuccess() {
        let cacheSpy = FeedCacheSpy()
        let expectedFeed = makeUniqueFeed()
        let sut = makeSUT(with: .success(expectedFeed), cache: cacheSpy)
        
        sut.load { _ in }
        
        XCTAssertEqual(cacheSpy.messages, [.save(expectedFeed)])
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let cacheSpy = FeedCacheSpy()
        let sut = makeSUT(with: .failure(anyNSError()), cache: cacheSpy)
        
        sut.load { _ in }
        
        XCTAssertTrue(cacheSpy.messages.isEmpty, "Expected not to cache feed on load error")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(with loaderResult: FeedLoader.Result, cache: FeedCacheSpy = .init(), file: StaticString = #file, line: UInt = #line) -> FeedLoaderCacheDecorator {
        let stub = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: stub, cache: cache)
        trackForMemoryLeaks(stub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class FeedCacheSpy: FeedCache {
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        private(set) var messages = [Message]()
        
        func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feed))
            completion(.success(()))
        }
    }
}

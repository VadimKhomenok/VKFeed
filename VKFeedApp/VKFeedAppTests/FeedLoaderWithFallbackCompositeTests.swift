//
//  RemoteLoaderWithLocalFallbackLoaderCompositeTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 3.06.22.
//

import XCTest
import VKFeed
import VKFeedApp

class FeedLoaderWithFallbackCompositeTests: XCTestCase, FeedLoaderTestCase {
    
    func test_loadFeed_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = makeUniqueFeed()
        let fallbackFeed = makeUniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(primaryFeed))
    }
    
    func test_loadFeed_deliversFallbackFeedOnPrimaryFeedLoaderFailure() {
        let fallbackFeed = makeUniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut, toCompleteWith: .success(fallbackFeed))
    }
    
    func test_loadFeed_deliversErrorOnPrimaryAndFallbackLoadersFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryStub = FeedLoaderStub(result: primaryResult)
        let fallbackStub = FeedLoaderStub(result: fallbackResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryStub, fallback: fallbackStub)
        
        trackForMemoryLeaks(primaryStub, file: file, line: line)
        trackForMemoryLeaks(fallbackStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}



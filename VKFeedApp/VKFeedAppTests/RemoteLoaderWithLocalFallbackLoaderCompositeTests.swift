//
//  RemoteLoaderWithLocalFallbackLoaderCompositeTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 3.06.22.
//

import XCTest
import VKFeed

class FeedLoaderWithFallbackComposite {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

class RemoteLoaderWithLocalFallbackLoaderCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = makeUniqueFeed()
        let fallbackFeed = makeUniqueFeed()
        let sut = makeSUT(primaryLoaderResult: .success(primaryFeed), fallbackLoaderResult: .success(fallbackFeed))
        
        expect(sut, toLoad: primaryFeed)
    }
    
    func test_loadFeed_deliversFallbackFeedOnPrimaryFeedLoaderFailure() {
        let fallbackFeed = makeUniqueFeed()
        let sut = makeSUT(primaryLoaderResult: .failure(anyNSError()), fallbackLoaderResult: .success(fallbackFeed))
        
        expect(sut, toLoad: fallbackFeed)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(primaryLoaderResult: FeedLoader.Result, fallbackLoaderResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> FeedLoaderWithFallbackComposite {
        let primaryLoaderStub = FeedLoaderStub(result: primaryLoaderResult)
        let fallbackLoaderStub = FeedLoaderStub(result: fallbackLoaderResult)
        let sut = FeedLoaderWithFallbackComposite(primary: primaryLoaderStub, fallback: fallbackLoaderStub)
        
        trackForMemoryLeaks(primaryLoaderStub, file: file, line: line)
        trackForMemoryLeaks(fallbackLoaderStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: FeedLoaderWithFallbackComposite, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        sut.load() { result in
            switch result {
            case let .success(resultFeed):
                XCTAssertEqual(resultFeed, expectedFeed, "Expected to receive \(expectedFeed) feed, received \(resultFeed) instead")
                
            case .failure:
                XCTFail("Expected load to succeed")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class FeedLoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(self.result)
        }
    }
}



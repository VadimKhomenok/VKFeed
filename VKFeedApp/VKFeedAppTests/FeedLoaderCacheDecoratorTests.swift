//
//  FeedLoaderCacheDecoratorTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation
import XCTest
import VKFeed

class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load(completion: completion)
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let expectedFeed = makeUniqueFeed()
        let remoteStub = FeedLoaderStub(result: .success(expectedFeed))
        let sut = FeedLoaderCacheDecorator(decoratee: remoteStub)
        
        expect(sut, toCompleteWith: .success(expectedFeed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let remoteStub = FeedLoaderStub(result: .failure(anyNSError()))
        let sut = FeedLoaderCacheDecorator(decoratee: remoteStub)
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    // MARK: - Helpers
    
    private func expect(_ sut: FeedLoaderCacheDecorator, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load to complete")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
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

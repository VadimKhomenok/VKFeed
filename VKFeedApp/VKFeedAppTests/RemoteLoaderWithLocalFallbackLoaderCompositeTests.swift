//
//  RemoteLoaderWithLocalFallbackLoaderCompositeTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 3.06.22.
//

import XCTest
import VKFeed

class RemoteLoaderWithLocalFallbackLoaderComposite {
    private let remoteFeedLoader: FeedLoader
    private let localFeedLoader: FeedLoader
    
    init(remoteFeedLoader: FeedLoader, localFeedLoader: FeedLoader) {
        self.remoteFeedLoader = remoteFeedLoader
        self.localFeedLoader = localFeedLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        remoteFeedLoader.load { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                self?.localFeedLoader.load(completion: completion)
            }
        }
    }
}

class RemoteLoaderWithLocalFallbackLoaderCompositeTests: XCTestCase {
    func test_loadFeed_deliversRemoteFeedOnRemoteSuccess() {
        let remoteFeed = makeUniqueFeed()
        let localFeed = makeUniqueFeed()
        let sut = makeSUT(remoteLoaderResult: .success(remoteFeed), localLoaderResult: .success(localFeed))
        
        expect(sut, toLoad: remoteFeed)
    }
    
    func test_loadFeed_deliversLocalFeedOnRemoteFeedFailure() {
        let localFeed = makeUniqueFeed()
        let sut = makeSUT(remoteLoaderResult: .failure(anyNSError()), localLoaderResult: .success(localFeed))
        
        expect(sut, toLoad: localFeed)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(remoteLoaderResult: FeedLoader.Result, localLoaderResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) -> RemoteLoaderWithLocalFallbackLoaderComposite {
        let remoteLoaderStub = RemoteFeedLoaderStub(result: remoteLoaderResult)
        let localLoaderStub = LocalFeedLoaderStub(result: localLoaderResult)
        let sut = RemoteLoaderWithLocalFallbackLoaderComposite(remoteFeedLoader: remoteLoaderStub, localFeedLoader: localLoaderStub)
        
        trackForMemoryLeaks(remoteLoaderStub, file: file, line: line)
        trackForMemoryLeaks(localLoaderStub, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func expect(_ sut: RemoteLoaderWithLocalFallbackLoaderComposite, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
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
    
    private func makeUniqueFeed() -> [FeedImage] {
        return [FeedImage(id: UUID(), description: nil, location: nil, url: anyURL()),
                FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())]
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://api-url.com")!
    }
    
    private class RemoteFeedLoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(self.result)
        }
    }
    
    private class LocalFeedLoaderStub: FeedLoader {
        private let result: FeedLoader.Result
        
        init(result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(self.result)
        }
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "An error", code: 400)
    }
}

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance is not deallocated, possible memory leak.", file: file, line: line)
        }
    }
}

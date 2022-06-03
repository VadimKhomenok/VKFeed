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
        let remoteLoaderStub = RemoteFeedLoaderStub(result: .success(remoteFeed))
        let localLoaderStub = LocalFeedLoaderStub(result: .success(localFeed))
        let sut = RemoteLoaderWithLocalFallbackLoaderComposite(remoteFeedLoader: remoteLoaderStub, localFeedLoader: localLoaderStub)
        
        let exp = expectation(description: "Wait for load to complete")
        sut.load() { result in
            switch result {
            case let .success(resultFeed):
                XCTAssertEqual(resultFeed, remoteFeed, "Expected to receive remote feed on Remote loader load success")
                
            case .failure:
                XCTFail("Expected load to succeed")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeed_deliversLocalFeedOnRemoteFeedFailure() {
        let remoteFeed = makeUniqueFeed()
        let localFeed = makeUniqueFeed()
        let remoteLoaderStub = RemoteFeedLoaderStub(result: .failure(anyNSError()))
        let localLoaderStub = LocalFeedLoaderStub(result: .success(localFeed))
        let sut = RemoteLoaderWithLocalFallbackLoaderComposite(remoteFeedLoader: remoteLoaderStub, localFeedLoader: localLoaderStub)
        
        let exp = expectation(description: "Wait for load to complete")
        sut.load() { result in
            switch result {
            case let .success(resultFeed):
                XCTAssertEqual(resultFeed, localFeed, "Expected to receive remote feed on Remote loader load success")
                
            case .failure:
                XCTFail("Expected load to succeed")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
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

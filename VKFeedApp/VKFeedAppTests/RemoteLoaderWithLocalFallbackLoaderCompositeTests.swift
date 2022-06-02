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
    
    init(remoteFeedLoader: FeedLoader) {
        self.remoteFeedLoader = remoteFeedLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        remoteFeedLoader.load(completion: completion)
    }
}

class RemoteLoaderWithLocalFallbackLoaderCompositeTests: XCTestCase {
    
    func test_loadFeed_deliversRemoteFeedOnRemoteSuccess() {
        let remoteFeed = makeUniqueFeed()
        let remoteLoaderStub = RemoteFeedLoaderStub(result: .success(remoteFeed))
        let sut = RemoteLoaderWithLocalFallbackLoaderComposite(remoteFeedLoader: remoteLoaderStub)
        
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
}

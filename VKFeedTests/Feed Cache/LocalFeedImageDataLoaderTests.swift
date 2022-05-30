//
//  LocalFeedImageDataLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 30.05.22.
//

import Foundation
import XCTest
import VKFeed

struct LocalFeedImageDataLoader {
    private let store: Any
    
    init(store: Any) {
        self.store = store
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_localFeedImageDataLoader_doesNotMessageStoreUponCreation() {
        let store = FeedStoreSpy()
        let _ = LocalFeedImageDataLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    private class FeedStoreSpy {
        enum ReceivedMessages: Equatable {
            case retrieve
        }
        
        var messages = [ReceivedMessages]()
    
        func retrieve() {
            messages.append(.retrieve)
        }
    }
}

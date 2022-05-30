//
//  LocalFeedImageDataLoaderTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 30.05.22.
//

import Foundation
import XCTest
import VKFeed

final class LocalFeedImageDataLoader {
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
    
    
    // MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
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

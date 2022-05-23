//
//  FeedPresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 23.05.22.
//

import XCTest
@testable import VKFeediOS

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_presenterLoad_doesNotSendMessagesToView() {
        let view = ViewSpy()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to view on initialization")
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}

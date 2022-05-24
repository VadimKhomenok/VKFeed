//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest

class FeedImagePresenter {
    var view: Any
    
    init(view: Any) {
        self.view = view
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_imagePresenterLoad_doesNotSendMessagesToView() {
        let view = ViewSpy()
        let _ = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected to not send messages to view on FeedImagePresenter load")
    }
    
    struct ViewSpy {
        var messages = [Any]()
    }
}

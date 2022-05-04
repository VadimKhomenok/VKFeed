//
//  FeedViewControllerTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 4.05.22.
//

import XCTest
import UIKit
import VKFeed

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {

    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }

    struct LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}

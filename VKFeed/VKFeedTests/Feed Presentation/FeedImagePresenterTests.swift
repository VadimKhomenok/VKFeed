//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest
import VKFeed
import UIKit

class FeedImagePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let feedImage = makeUniqueImage()
        
        let viewModel = FeedImagePresenter.map(feedImage)
        
        XCTAssertEqual(viewModel.location, feedImage.location)
        XCTAssertEqual(viewModel.description, feedImage.description)
    }
}

//
//  VKFeedAppUIAcceptanceTests.swift
//  VKFeedAppUIAcceptanceTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import XCTest

class VKFeedAppUIAcceptanceTests: XCTestCase {
    func test_launch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        
        app.launch()
        
        let feedImageCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedImageCells.count, 22)
        
        let feedImage = app.cells.firstMatch.images.matching(identifier: "feed-image-view")
        XCTAssertEqual(feedImage.count, 1)
    }
}

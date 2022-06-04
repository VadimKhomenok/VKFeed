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
        
        XCTAssertEqual(app.cells.count, 22)
//        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}

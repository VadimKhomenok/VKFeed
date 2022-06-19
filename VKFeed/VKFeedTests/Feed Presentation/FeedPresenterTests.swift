//
//  FeedPresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 23.05.22.
//

import XCTest
import VKFeed

class FeedPresenterTests: XCTestCase {
    
    func test_presenter_hasLocalizedTitle() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_presenter_createsViewModel() {
        let feed = [makeUniqueImage()]
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    // MARK: - Helpers

    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}

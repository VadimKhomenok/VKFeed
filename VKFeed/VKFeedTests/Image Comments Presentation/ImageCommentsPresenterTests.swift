//
//  ImageCommentsPresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.06.22.
//

import XCTest
import VKFeed

class ImageCommentsPresenterTests: XCTestCase {
    func test_presenter_hasLocalizedTitle() {
        XCTAssertEqual(ImageCommentsPresenter.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}

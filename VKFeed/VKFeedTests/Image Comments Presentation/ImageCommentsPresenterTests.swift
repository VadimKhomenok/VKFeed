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
    
    func test_presenter_createsViewModel() {
        
        let comments = [
            ImageComment(
                id: UUID(),
                message: "a message",
                createdAt: Date().adding(minutes: -5),
                username: "username"),
            ImageComment(
                id: UUID(),
                message: "another message",
                createdAt: Date().adding(days: -2),
                username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(comments)
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(
                message: "a message",
                date: "5 minutes ago",
                username: "username"),
            ImageCommentViewModel(
                message: "another message",
                date: "2 days ago",
                username: "another username"
            )
        ])
    }
    
    // MARK: - Helpers
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
}

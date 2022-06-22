//
//  FeedViewControllerTests+Assertions.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeediOS
import VKFeed
import XCTest
    
extension FeedUIIntegrationTests {
    func assert(sut: ListViewController, rendered feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        XCTAssertEqual(sut.numberOfRenderedFeedViews(), feed.count, "Expected to render \(feed.count) number of views, rendered \(sut.numberOfRenderedFeedViews()) instead", file: file, line: line)
        
        for (index, feedImage) in feed.enumerated() {
            assert(sut: sut, hasViewConfigured: feedImage, at: index)
        }
        
        executeRunLoopToCleanUpReferences()
    }
    
    func assert(sut: ListViewController, hasViewConfigured feedImage: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.renderedFeedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected to get \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = feedImage.location != nil
        let shouldDescriptionBeVisible = feedImage.description != nil

        XCTAssertEqual(cell.descriptionText, feedImage.description, "Expected description text to be \(String(describing: feedImage.description)) for image  view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.locationText, feedImage.location, "Expected location text to be \(String(describing: feedImage.location)) for image  view at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.locationIsVisible, shouldLocationBeVisible, "Expected `locationIsVisible` to be \(shouldLocationBeVisible) for cell at index (\(index))", file: file, line: line)
        XCTAssertEqual(cell.descriptionIsVisible, shouldDescriptionBeVisible, "Expected `descriptionIsVisible` to be \(shouldDescriptionBeVisible) for cell at index (\(index))", file: file, line: line)
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}

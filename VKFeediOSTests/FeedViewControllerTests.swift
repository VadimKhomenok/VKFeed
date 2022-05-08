//
//  FeedViewControllerTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 4.05.22.
//

import XCTest
import UIKit
import VKFeed
import VKFeediOS

final class FeedViewControllerTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading is completed")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: "another description", location: nil)
        let image2 = makeImage(description: nil, location: "another location")
        let image3 = makeImage(description: nil, location: nil)

        sut.loadViewIfNeeded()
        assert(sut: sut, rendered: [])
        
        loader.completeFeedLoading(feed: [image0], at: 0)
        assert(sut: sut, rendered: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(feed: [image0, image1, image2, image3], at: 1)
        assert(sut: sut, rendered: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletionWithError_doesNotAlterCurrentRenderedFeed() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0], at: 0)
        assert(sut: sut, rendered: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 1)
        assert(sut: sut, rendered: [image0])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func assert(sut: FeedViewController, rendered feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedFeedViews(), feed.count, "Expected to render \(feed.count) number of views, rendered \(sut.numberOfRenderedFeedViews()) instead", file: file, line: line)
        
        for (index, feedImage) in feed.enumerated() {
            assert(sut: sut, hasViewConfigured: feedImage, at: index)
        }
    }
    
    private func assert(sut: FeedViewController, hasViewConfigured feedImage: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
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
    
    private func makeImage(description: String?, location: String?, url: URL = URL(string: "https://api-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }

    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(feed: [FeedImage] = [], at index: Int) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoading(with error: Error, at index: Int) {
            completions[index](.failure(error))
        }
    }
}

private extension FeedImageCell {
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var locationIsVisible: Bool {
        return !locationContainer.isHidden
    }
    
    var descriptionIsVisible: Bool {
        return !descriptionLabel.isHidden
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    func feedImagesSection() -> Int {
        return 0
    }
    
    func renderedFeedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: row, section: feedImagesSection())
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func numberOfRenderedFeedViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection())
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { (target as NSObject).perform(Selector($0))
            }
        }
    }
}

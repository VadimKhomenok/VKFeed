//
//  CommentsUIIntegrationTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 27.06.22.
//

import XCTest
import UIKit
import VKFeed
import VKFeediOS
@testable import VKFeedApp

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    override func test_feedView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, loadFeedTitle)
    }
    
    override func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    override func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading is completed with success")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator after loading is completed with error")
    }

    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeedAfterOnceSuccessfullyLoaded() {
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
    
    override func test_loadFeedCompletionWithError_doesNotAlterCurrentRenderedFeed() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage(description: "a description", location: "a location")
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0], at: 0)
        assert(sut: sut, rendered: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 1)
        assert(sut: sut, rendered: [image0])
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
    
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        assert(sut: sut, rendered: [image0, image1])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(feed: [], at: 1)
        assert(sut: sut, rendered: [])
    }

    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Complete feed load in background thread")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNil(sut.errorMessage, "Expected no error message on feed view loaded")
        
        loader.completeFeedLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, loadError, "Expected to render error message on feed load failure")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertNil(sut.errorMessage, "Expected no error message after user initiated reload")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: ListViewController) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: { loader.loadPublisher() })
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://api-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
}

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
@testable import VKFeedApp

final class FeedUIIntegrationTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }
    
    func test_feedView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, localized("FEED_VIEW_TITLE"))
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
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
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading is completed with success")
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: anyNSError(), at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator after loading is completed with error")
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeedAfterOnceSuccessfullyLoaded() {
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
    
    func test_feedViewIsVisible_loadsImageFromURL() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage()
        let image1 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        XCTAssertTrue(loader.imageRequests.isEmpty, "Expected not to load image urls until view is not visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [image0.url], "Expected to load url for first image")
    
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url], "Expected to load url for both images")
    }
    
    func test_feedViewIsHidden_cancelsLoadImageFromURL() {
        let (loader, sut) = makeSUT()
        let image0 = makeImage()
        let image1 = makeImage()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        XCTAssertTrue(loader.cancelledRequestedUrls.isEmpty, "Expected not to cancel load image urls until view becomes hidden")
        
        sut.simulateFeedImageViewHidden(at: 0)
        XCTAssertEqual(loader.cancelledRequestedUrls, [image0.url], "Expected to cancel load url for first image")
    
        sut.simulateFeedImageViewHidden(at: 1)
        XCTAssertEqual(loader.cancelledRequestedUrls, [image0.url, image1.url], "Expected to cancel load url for second image while first remains cancelled from the previous step")
    }
    
    func test_feedViewLoadingIndicator_isVisibleDuringTheImageUrlLoading() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected first view to display loading indicator when first image load is initiated")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second view to display loading indicator when second image load is initiated")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected first view to hide loading indicator when first image load is completed")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected second view to still show loading indicator when first image load is completed but second image load is not completed yet")
        
        loader.completeImageLoading(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected first view to still have hidden loading indicator when second image load is completed")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected second view to hide loading indicator when second image load is completed")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected first image not to be rendered until load is completed")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected second image not to be rendered until load is completed")
        
        let imageData0 = UIImage.makeTinyImage(color: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")
        
        let imageData1 = UIImage.makeTinyImage(color: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    func test_feedImageView_showsRetryButtonOnLoadError() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
    
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected view to not show retry button when first image loading just started")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected second view to not show retry button when second image loading just started")
        
        let imageData = UIImage.makeTinyImage(color: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 0)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected view to not show retry button when first image loaded successfully")
        XCTAssertEqual(view1?.isShowingRetryButton, false, "Expected second view to not show retry button when second image loading just started")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected view to not show retry button when first image loaded successfully")
        XCTAssertEqual(view1?.isShowingRetryButton, true, "Expected second view to show retry button when second image loading is failed with error")
    }
    
    func test_feedImageView_showsRetryButtonInvalidLoadedImageData() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, false, "Expected view to not show retry button when image loading just started")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, true, "Expected view to show retry button when image loading is succeeded but with invalid data")
    }
    
    func test_feedImageViewRetry_retryLoadOfFailedImage() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url], "Expected only two image URL requests before retry action")

        view0?.simulateFeedImageViewRetry()
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateFeedImageViewRetry()
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageUrls, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageUrls, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledRequestedUrls, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledRequestedUrls, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledRequestedUrls, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
    
        loader.completeFeedLoading(feed: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewHidden(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when image load finishes after the view is not visible anymore")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
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

    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Complete feed load in background thread")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(feed: [makeImage()], at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        
        let exp = expectation(description: "Complete feed image load in background thread")
        DispatchQueue.global().async {
            loader.completeImageLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNil(sut.errorMessage, "Expected no error message on feed view loaded")
        
        loader.completeFeedLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, localized("GENERIC_CONNECTION_ERROR"), "Expected to render error message on feed load failure")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertNil(sut.errorMessage, "Expected no error message after user initiated reload")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (loader: LoaderSpy, sut: FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(imageLoader: loader.loadImageDataPublisher, feedLoader: loader.loadPublisher)
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://api-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func anyImageData() -> Data {
        return UIImage.makeTinyImage(color: .red).pngData()!
    }
}

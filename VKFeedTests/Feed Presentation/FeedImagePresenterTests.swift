//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest
import VKFeed

struct FeedImageViewData<Image> {
    var description: String?
    var location: String?
    var isLoading: Bool
    var isRetry: Bool
    var image: Image?
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewData<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    var view: View
    var imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: true,
            isRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: image))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: true))
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_imagePresenterLoad_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected to not send messages to view on FeedImagePresenter load")
    }
    
    func test_didStartLoadingImageData_displayLoadingDataAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.isRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetryAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetry, true)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageDataWithSuccess_displaysImageDataAndModelDetails() {
        let feedImage = makeUniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: anyData(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetailsOnImageTranformationFailure() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let feedImage = makeUniqueImage()
        
        sut.didFinishLoadingImageData(with: anyData(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.isRetry, true)
        XCTAssertNil(message?.image)
    }
    
    
    // MARK: - Helpers
    
    private struct AnyImage: Equatable {}
    private typealias ImageTransformerClosure = (Data) -> AnyImage?
    
    private var fail: ImageTransformerClosure {
        return { _ in nil }
    }

    private func makeSUT(imageTransformer: @escaping ImageTransformerClosure = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }

    private final class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewData<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewData<AnyImage>) {
            messages.append(viewModel)
        }
    }
}

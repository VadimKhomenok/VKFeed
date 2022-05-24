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
        let loadingModel = loadingViewModel(model: feedImage)
        
        sut.didStartLoadingImageData(for: feedImage)
        assert(model: loadingModel, equal: view.messages.first)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let retryModel = retryViewModel(model: feedImage)
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        assert(model: retryModel, equal: view.messages.first)
    }
    
    func test_didFinishLoadingImageData_displaysImageDataAndModelDetails() {
        let feedImage = makeUniqueImage()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        let imageDataModel = imageDataModel(image: transformedData, model: feedImage)
        
        sut.didFinishLoadingImageData(with: anyData(), for: feedImage)
        assert(model: imageDataModel, equal: view.messages.first)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetailsOnImageTranformationFailure() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let feedImage = makeUniqueImage()
        
        let retryDataModel = retryViewModel(model: feedImage)
        
        sut.didFinishLoadingImageData(with: anyData(), for: feedImage)
        assert(model: retryDataModel, equal: view.messages.first)
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
    
    private func assert(model: FeedImageViewData<AnyImage>, equal expectedModel: FeedImageViewData<AnyImage>?, file: StaticString = #file, line: UInt = #line) {
        guard let expectedModel = expectedModel else {
            XCTFail("Expected that display message contains model, received nil instead")
            return
        }
        
        XCTAssertEqual(model.description, expectedModel.description, file: file, line: line)
        XCTAssertEqual(model.location, expectedModel.location, file: file, line: line)
        XCTAssertEqual(model.isLoading, expectedModel.isLoading, file: file, line: line)
        XCTAssertEqual(model.isRetry, expectedModel.isRetry, file: file, line: line)
        XCTAssertEqual(model.image, expectedModel.image, file: file, line: line)
    }

    private final class ViewSpy: FeedImageView {
        private(set) var messages = [FeedImageViewData<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewData<AnyImage>) {
            messages.append(viewModel)
        }
    }
    
    private func loadingViewModel(model: FeedImage) -> FeedImageViewData<AnyImage> {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: true,
            isRetry: false,
            image: nil)
    }
    
    private func retryViewModel(model: FeedImage) -> FeedImageViewData<AnyImage> {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: true,
            image: nil)
    }
    
    private func imageDataModel(image: AnyImage, model: FeedImage) -> FeedImageViewData<AnyImage> {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: image)
    }
}

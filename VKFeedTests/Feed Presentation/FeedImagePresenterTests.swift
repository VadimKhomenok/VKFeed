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
        
        XCTAssertNil(view.message, "Expected to not send messages to view on FeedImagePresenter load")
    }
    
    func test_didStartLoadingImageData_displayLoadingDataAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let loadingModel = loadingViewModel(model: feedImage)
        
        sut.didStartLoadingImageData(for: feedImage)
        assert(model: loadingModel, relevantTo: view.message)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let retryModel = retryViewModel(model: feedImage)
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        assert(model: retryModel, relevantTo: view.message)
    }
    
    func test_didFinishLoadingImageData_displaysImageDataAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let imageData = anyData()
        let image = Self.succeedableImageTransformer(imageData)!
        
        let imageDataModel = imageDataModel(image: image, model: feedImage)
        
        sut.didFinishLoadingImageData(with: imageData, for: feedImage)
        assert(model: imageDataModel, relevantTo: view.message)
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetailsOnImageTranformationFailure() {
        let (sut, view) = makeSUT(imageTransformer: Self.failableImageTransformer)
        let feedImage = makeUniqueImage()
        let imageData = anyData()
        
        let retryDataModel = retryViewModel(model: feedImage)
        
        sut.didFinishLoadingImageData(with: imageData, for: feedImage)
        assert(model: retryDataModel, relevantTo: view.message)
    }
    
    
    // MARK: - Helpers
    
    private typealias ImageTransformerClosure = (Data) -> AnyImage?
    
    private static var succeedableImageTransformer: ImageTransformerClosure = {_ in
        return AnyImage()
    }
    
    private static var failableImageTransformer: ImageTransformerClosure = { _ in
        return nil
    }
    
    private struct AnyImage: Equatable {}
    
    private func makeSUT(imageTransformer: @escaping ImageTransformerClosure = succeedableImageTransformer, file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, view)
    }
    
    private func assert(model: FeedImageViewData<AnyImage>, relevantTo displayMessage: ViewSpy.DisplayMessage?, file: StaticString = #file, line: UInt = #line) {
        guard let expectedModel = displayMessage?.model else {
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
        
        struct DisplayMessage {
            var model: FeedImageViewData<AnyImage>
        }
        
        var message: DisplayMessage?
        
        func display(_ viewModel: FeedImageViewData<AnyImage>) {
            message = DisplayMessage(model: viewModel)
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

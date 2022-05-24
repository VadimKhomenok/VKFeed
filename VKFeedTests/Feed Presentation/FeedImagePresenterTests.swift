//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest
import VKFeed

struct FeedImageViewData: Equatable {
    var description: String?
    var location: String?
    var isLoading: Bool
    var isRetry: Bool
    var image: UIImage?
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewData)
}

final class FeedImagePresenter {
    var view: FeedImageView
    var imageTransformer: (Data) -> UIImage?
    
    init(view: FeedImageView, imageTransformer: @escaping (Data) -> UIImage?) {
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
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: imageTransformer(data)))
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
        XCTAssertEqual(view.messages, [ViewSpy.DisplayMessage(model: loadingModel)])
    }
    
    func test_didFinishLoadingImageData_displaysRetryAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let retryModel = retryViewModel(model: feedImage)
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        XCTAssertEqual(view.messages, [ViewSpy.DisplayMessage(model: retryModel)])
    }
    
    func test_didFinishLoadingImageData_displaysImageDataAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let imageData = anyData()
        let image = UIImage()
        let imageDataModel = imageDataModel(image: image, model: feedImage)
        
        sut.didFinishLoadingImageData(with: imageData, for: feedImage)
        XCTAssertEqual(view.messages, [ViewSpy.DisplayMessage(model: imageDataModel)])
    }
    
    
    // MARK: - Helpers
    
    private typealias ImageTransformerClosure = (Data) -> UIImage?
    
    private static var imageTransformerSuccess: ImageTransformerClosure = {_ in
        return UIImage()
    }
    
    private static var imageTransformerFailing: ImageTransformerClosure = { _ in
        return nil
    }
    
    private func makeSUT(imageTransformer: @escaping ImageTransformerClosure = imageTransformerSuccess) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }

    private final class ViewSpy: FeedImageView {
        
        struct DisplayMessage: Equatable {
            var model: FeedImageViewData
        }
        
        var messages = [DisplayMessage]()
        
        func display(_ viewModel: FeedImageViewData) {
            messages.append(DisplayMessage(model: viewModel))
        }
    }
    
    private func loadingViewModel(model: FeedImage) -> FeedImageViewData {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: true,
            isRetry: false,
            image: nil)
    }
    
    private func retryViewModel(model: FeedImage) -> FeedImageViewData {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: true,
            image: nil)
    }
    
    private func imageDataModel(image: UIImage, model: FeedImage) -> FeedImageViewData {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: image)
    }
}

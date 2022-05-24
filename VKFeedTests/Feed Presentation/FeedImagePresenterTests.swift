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
    var image: Data?
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewData)
}

final class FeedImagePresenter {
    var view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
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
            image: data))
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
        let imageDataModel = imageDataModel(imageData: imageData, model: feedImage)
        
        sut.didFinishLoadingImageData(with: imageData, for: feedImage)
        XCTAssertEqual(view.messages, [ViewSpy.DisplayMessage(model: imageDataModel)])
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        
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
    
    private func imageDataModel(imageData: Data, model: FeedImage) -> FeedImageViewData {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: imageData)
    }
}

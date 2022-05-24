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
}

class FeedImagePresenterTests: XCTestCase {
    func test_imagePresenterLoad_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected to not send messages to view on FeedImagePresenter load")
    }
    
    func test_didStartLoadingImageData_displayLoadingDataAndModelDetails() {
        let (sut, view) = makeSUT()
        let feedImage = makeUniqueImage()
        let loadingModel = startLoadingViewModel(model: feedImage)
        
        sut.didStartLoadingImageData(for: feedImage)
        XCTAssertEqual(view.messages, [ViewSpy.DisplayMessage(model: loadingModel)])
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
    
    private func startLoadingViewModel(model: FeedImage) -> FeedImageViewData {
        return FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: true,
            isRetry: false)
    }
}

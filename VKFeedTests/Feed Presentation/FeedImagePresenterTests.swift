//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest

struct FeedImageViewData: Equatable {
    var isLoading: Bool
}

protocol FeedImageView {
    func display(_ viewModel: FeedImageViewData)
}

final class FeedImagePresenter {
    var view: FeedImageView
    
    init(view: FeedImageView) {
        self.view = view
    }
    
    func didStartLoadingImageData() {
        view.display(FeedImageViewData(isLoading: true))
    }
}

class FeedImagePresenterTests: XCTestCase {
    func test_imagePresenterLoad_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected to not send messages to view on FeedImagePresenter load")
    }
    
    func test_didStartLoadingImageData_displayLoadingData() {
        let (sut, view) = makeSUT()
        
        let loadingModel = FeedImageViewData(isLoading: true)
        sut.didStartLoadingImageData()
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
}

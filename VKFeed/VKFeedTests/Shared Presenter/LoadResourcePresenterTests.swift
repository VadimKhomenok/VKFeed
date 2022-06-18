//
//  LoadResourcePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 18.06.22.
//

import XCTest
import VKFeed

class LoadResourcePresenterTests: XCTestCase {

    func test_presenterLoad_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no messages to view on initialization")
    }
    
    func test_didStartLoadingResource_noErrorAndLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none),
                                       .display(isLoading: true)])
    }
    
    func test_didFinishLoadingWithResource() {
        let (sut, view) = makeSUT()
        let resource = "a resource"
        
        sut.didFinishLoading(with: resource)
        XCTAssertEqual(view.messages, [.display(resource: resource),
                                       .display(isLoading: false)])
    }
    
    func test_didFinishLoadingWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false),
                                       .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR"))])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LoadResourcePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(loadingView: view, resourceView: view, resourceLoadErrorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private class ViewSpy: ResourceLoadingView, ResourceLoadErrorView, ResourceView {

        enum Messages: Hashable {
            case display(resource: String)
            case display(isLoading: Bool)
            case display(errorMessage: String?)
        }
        
        private(set) var messages = Set<Messages>()
        
        func display(_ viewModel: ResourceLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: ResourceViewModel) {
            messages.insert(.display(resource: viewModel.resource))
        }
        
        func display(_ viewModel: ResourceLoadErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}

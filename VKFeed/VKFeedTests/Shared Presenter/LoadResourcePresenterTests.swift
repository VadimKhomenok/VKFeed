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
        let resource = "a resource"
        
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: resource)
        XCTAssertEqual(view.messages, [.display(resource: "a resource view model"),
                                       .display(isLoading: false)])
    }
    
    func test_didFinishLoadingWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(isLoading: false),
                                       .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR"))])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = LoadResourcePresenter(loadingView: view, resourceView: view, resourceLoadErrorView: view, mapper: mapper)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }
    
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private class ViewSpy: ResourceLoadingView, ResourceLoadErrorView, ResourceView {
        typealias ResourceViewModel = String
        
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
            messages.insert(.display(resource: viewModel))
        }
        
        func display(_ viewModel: ResourceLoadErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }
}

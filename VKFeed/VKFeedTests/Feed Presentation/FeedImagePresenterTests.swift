//
//  FeedImagePresenterTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 24.05.22.
//

import XCTest
import VKFeed
import UIKit

class FeedImagePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let feedImage = makeUniqueImage()
        
        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(feedImage)
        
        XCTAssertEqual(viewModel.location, feedImage.location)
        XCTAssertEqual(viewModel.description, feedImage.description)
    }
    
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
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }
}

extension UIImage {
    static func makeTinyImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

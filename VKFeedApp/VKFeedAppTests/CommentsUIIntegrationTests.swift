//
//  CommentsUIIntegrationTests.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 27.06.22.
//

import XCTest
import UIKit
import VKFeed
import VKFeediOS
import Combine
@testable import VKFeedApp

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    override func setUp() {
        continueAfterFailure = false
    }
    
    func test_commentsView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once view is loaded")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once loading is completed")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator(), "Expected loading indicator once user initiates a reload")
        
        loader.completeCommentsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator once user initiated loading is completed with success")
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: anyNSError(), at: 2)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator(), "Expected no loading indicator after loading is completed with error")
    }

    func test_loadCommentsCompletion_rendersSuccessfullyLoadedCommentsAfterOnceSuccessfullyLoaded() {
        let (loader, sut) = makeSUT()
        let comment0 = makeComment(message: "message", username: "username")
        let comment1 = makeComment(message: "another message", username: "another username")

        sut.loadViewIfNeeded()
        assert(sut: sut, rendered: [ImageComment]())
        
        loader.completeCommentsLoading(comments: [comment0], at: 0)
        assert(sut: sut, rendered: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(comments: [comment0, comment1], at: 1)
        assert(sut: sut, rendered: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
    
        loader.completeCommentsLoading(comments: [comment], at: 0)
        assert(sut: sut, rendered: [comment])

        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(comments: [], at: 1)
        assert(sut: sut, rendered: [ImageComment]())
    }
    
    func test_loadCommentsCompletionWithError_doesNotAlterCurrentRenderedComments() {
        let (loader, sut) = makeSUT()
        let comment = makeComment()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(comments: [comment], at: 0)
        assert(sut: sut, rendered: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: anyNSError(), at: 1)
        assert(sut: sut, rendered: [comment])
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }

    override func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Complete feed load in background thread")
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertNil(sut.errorMessage, "Expected no error message on feed view loaded")
        
        loader.completeCommentsLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(sut.errorMessage, loadError, "Expected to render error message on feed load failure")
        
        sut.simulateUserInitiatedReload()
        XCTAssertNil(sut.errorMessage, "Expected no error message after user initiated reload")
    }
    
    
    // MARK: - Helpers
    
    private class LoaderSpy {
        private var requests = [PassthroughSubject<[ImageComment], Swift.Error>]()
        
        var loadCommentsCallCount: Int {
            requests.count
        }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Swift.Error> {
            let publisher = PassthroughSubject<[ImageComment], Swift.Error>()
            requests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(comments: [ImageComment] = [], at index: Int) {
            requests[index].send(comments)
        }
        
        func completeCommentsLoading(with error: Error, at index: Int) {
            requests[index].send(completion: .failure(error))
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (loader: LoaderSpy, sut: ListViewController) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: { loader.loadPublisher() })
        
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (loader, sut)
    }
    
    private func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    private func assert(sut: ListViewController, rendered comments: [ImageComment], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedImageCommentsViews(), comments.count, "Expected to render \(comments.count) number of views, rendered \(sut.numberOfRenderedImageCommentsViews()) instead", file: file, line: line)
        
        let viewModel = ImageCommentsPresenter.map(comments: comments)
        
        viewModel.comments.enumerated().forEach { index, commentModel in
            XCTAssertEqual(sut.commentMessage(at: index), commentModel.message)
            XCTAssertEqual(sut.commentDate(at: index), commentModel.date)
            XCTAssertEqual(sut.commentUsername(at: index), commentModel.username)
        }
    }
}

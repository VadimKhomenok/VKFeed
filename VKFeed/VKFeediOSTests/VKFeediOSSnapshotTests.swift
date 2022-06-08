//
//  VKFeediOSSnapshotTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 8.06.22.
//

import XCTest
import VKFeediOS
@testable import VKFeed

class VKFeediOSSnapshotTests: XCTestCase {
    
    func test_emptyFeed_snapshot() {
        let feed = makeSUT()
        
        feed.display(stubs: [])
        
        record(snapshot: feed.snapshot(), named: "EMPTY_FEED")
    }
    
    func test_nonEmptyFeed_snapshot() {
        let feed = makeSUT()
        
        feed.display(stubs: feedWithContent())
        
        record(snapshot: feed.snapshot(), named: "FEED_WITH_CONTENT")
    }
    
    func test_errorFeed_snapshot() {
        let feed = makeSUT()
        
        feed.display(FeedErrorViewModel(message: "This is a\nmulti-line\nerror message"))
        
        record(snapshot: feed.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }
    
    func test_errorImageLoading_snapshot() {
        let feed = makeSUT()
        
        feed.display(stubs: feedWithFailedImageLoading())
        
        record(snapshot: feed.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        
        trackForMemoryLeaks(feedViewController)
        
        feedViewController.loadViewIfNeeded()
        
        return feedViewController
    }
    
    private func record(snapshot: UIImage, named: String, file: StaticString = #file, line: UInt = #line) {
        guard let imageData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
                        return
        }
        
        let snapshotURL = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(named).png")

        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)

            try imageData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.makeTinyImage(color: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.makeTinyImage(color: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }
}

private extension FeedViewController {
    func display(stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let cellController = FeedImageCellController(delegate: stub)
            stub.controller = cellController
            return cellController
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel<UIImage>.init(description: description,
                                                          location: location,
                                                          isLoading: false,
                                                          isRetry: image == nil,
                                                          image: image)
    }
    
    func didRequestImage() {
        controller?.display(viewModel)
    }
    
    func didCancelImageRequest() {}
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

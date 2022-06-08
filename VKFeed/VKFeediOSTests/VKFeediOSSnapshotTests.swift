//
//  VKFeediOSSnapshotTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 8.06.22.
//

import XCTest
import VKFeediOS

class VKFeediOSSnapshotTests: XCTestCase {
    
    func test_emptyFeed_snapshot() {
        let feed = makeSUT()
        
        feed.display([])
        
        let snapshot = feed.snapshot()
        
        record(snapshot: snapshot, named: "EMPTY_FEED")
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
}

extension UIViewController {
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

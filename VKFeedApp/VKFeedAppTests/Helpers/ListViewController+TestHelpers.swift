
//
//  ListViewController+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeediOS
import UIKit

extension ListViewController {
    
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()

        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        return renderedFeedImageView(at: row) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewHidden(at row: Int) -> FeedImageCell? {
        guard let cell = renderedFeedImageView(at: row) as? FeedImageCell else { return nil }
        let delegate = tableView.delegate
        let indexPath = feedImageIndexPath(for: row)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        return cell
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        dataSource?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let dataSource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    var feedImagesSection: Int { 0 }
    
    func feedImageIndexPath(for row: Int) -> IndexPath {
        return IndexPath(row: row, section: feedImagesSection)
    }

    @discardableResult
    func renderedFeedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedViews() > row else {
            return nil
        }

        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: feedImageIndexPath(for: row))
    }
    
    func numberOfRenderedFeedViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    var errorMessage: String? {
        return errorView.message
    }
}

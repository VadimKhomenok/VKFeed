//
//  FeedViewController+TestHelpers.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeediOS
import UIKit

extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
        return renderedFeedImageView(at: row) as? FeedImageCell
    }
    
    func simulateFeedImageViewHidden(at row: Int) {
        guard let cell = renderedFeedImageView(at: row) else { return }
        let delegate = tableView.delegate
        let indexPath = feedImageIndexPath(for: row)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
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
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    var feedImagesSection: Int { 0 }
    
    func feedImageIndexPath(for row: Int) -> IndexPath {
        return IndexPath(row: row, section: feedImagesSection)
    }

    @discardableResult
    func renderedFeedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: feedImageIndexPath(for: row))
    }
    
    func numberOfRenderedFeedViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
}

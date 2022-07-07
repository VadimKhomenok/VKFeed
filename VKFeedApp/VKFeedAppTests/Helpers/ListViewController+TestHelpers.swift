
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
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    func simulateLoadMoreErrorViewTap() {
        let delegate = tableView.delegate
        let index = IndexPath(row: feedLoadMoreIndexPath.row, section: feedLoadMoreIndexPath.section)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func isShowingLoadingIndicator() -> Bool {
        return refreshControl?.isRefreshing ?? false
    }

    var errorMessage: String? {
        return errorView.message
    }
    
    var loadMoreFeedErrorMessage: String? {
        return loadMoreFeedCell()?.message
    }
}

// MARK: - Table View Helpers

extension ListViewController {
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

// MARK: - Feed specific extension

extension ListViewController {
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
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let indexPath = feedImageIndexPath(for: row)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func simulateUserInitiatedLoadMoreAction() {
        guard let loadMoreCell = loadMoreFeedCell() else { return }
                
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, willDisplay: loadMoreCell, forRowAt: feedLoadMoreIndexPath)
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        return loadMoreFeedCell()?.isLoading == true
    }
    
    private func loadMoreFeedCell() -> LoadMoreCell? {
        cell(row: feedLoadMoreIndexPath.row, section: feedLoadMoreIndexPath.section) as? LoadMoreCell
    }
    
    var feedImagesSection: Int { 0 }
    var feedLoadMoreSection: Int { 1 }
    var feedLoadMoreIndexPath: IndexPath { IndexPath(row: 0, section: feedLoadMoreSection) }
    
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
}

// MARK: - Comments specific extension

extension ListViewController {
    var imageCommentsSection: Int { 0 }
    
    func numberOfRenderedImageCommentsViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: imageCommentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        return renderedImageCommentView(at: row)?.messageLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        return renderedImageCommentView(at: row)?.usernameLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        return renderedImageCommentView(at: row)?.dateLabel.text
    }
    
    func renderedImageCommentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedImageCommentsViews() > row else {
            return nil
        }

        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: imageCommentIndexPath(for: row)) as? ImageCommentCell
    }
    
    func imageCommentIndexPath(for row: Int) -> IndexPath {
        return IndexPath(row: row, section: imageCommentsSection)
    }
}

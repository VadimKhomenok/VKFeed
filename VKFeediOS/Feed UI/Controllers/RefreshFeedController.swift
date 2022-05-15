//
//  RefreshFeedController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private var feedViewPresenter: FeedViewPresenter
    
    private(set) lazy var refreshControl = loadView()
    
    init(feedViewPresenter: FeedViewPresenter) {
        self.feedViewPresenter = feedViewPresenter
    }
    
    @objc func refresh() {
        feedViewPresenter.loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
}

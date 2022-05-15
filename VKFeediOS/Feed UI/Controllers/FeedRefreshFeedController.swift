//
//  FeedRefreshFeedController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

protocol FeedRefreshViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var refreshControl = loadView()
    private var delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
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

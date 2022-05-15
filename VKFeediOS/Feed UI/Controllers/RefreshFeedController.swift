//
//  RefreshFeedController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private var feedViewModel: FeedViewModel
    
    private(set) lazy var refreshControl = binded(UIRefreshControl())
    
    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
    }
    
    @objc func refresh() {
        feedViewModel.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        feedViewModel.onLoadingStateChanged = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}

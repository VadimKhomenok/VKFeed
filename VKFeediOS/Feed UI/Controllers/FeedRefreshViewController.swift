//
//  FeedRefreshViewController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import UIKit

protocol FeedRefreshViewControllerDelegate: AnyObject {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    @IBOutlet private var refreshControl: UIRefreshControl!
    var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl.beginRefreshing()
        } else {
            refreshControl.endRefreshing()
        }
    }
}

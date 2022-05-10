//
//  RefreshFeedController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import UIKit

public class FeedRefreshController: NSObject {
    private let feedLoader: FeedLoader
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        return refreshControl
    }()
    
    var refreshComplete: (([FeedImage]) -> Void)?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    @objc func load() {
        refreshControl.beginRefreshing()
        feedLoader.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.refreshComplete?(feed)
            }
                
            self?.refreshControl.endRefreshing()
        })
    }
}

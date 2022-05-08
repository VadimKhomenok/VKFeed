//
//  FeedViewController.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 5.05.22.
//

import UIKit
import VKFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    
    private var tableModel = [FeedImage]()
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load(completion: { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
                
            self?.refreshControl?.endRefreshing()
        })
    }
    
    // MARK: - UITableView Data Source
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        let model = tableModel[indexPath.row]
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.locationContainer.isHidden = (model.location == nil)
        cell.descriptionLabel.isHidden = (model.description == nil)
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        cell.feedImageContainer.startShimmering()
        tasks[indexPath] = imageLoader?.loadImageData(from: model.url, completion: { [weak cell] result in
            let data = try? result.get()
            cell?.feedImageView.image = data.map(UIImage.init) ?? nil
            cell?.retryButton.isHidden = (data != nil)
            cell?.feedImageContainer.stopShimmering()
        })
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}

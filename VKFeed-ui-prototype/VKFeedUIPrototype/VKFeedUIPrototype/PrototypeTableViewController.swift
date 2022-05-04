//
//  PrototypeTableViewController.swift
//  VKFeedUIPrototype
//
//  Created by Vadim Khomenok on 1.05.22.
//

import UIKit

struct FeedImageViewModel {
    var description: String?
    var location: String?
    var imageName: String
}

class PrototypeTableViewController: UITableViewController {
    private var feed = [FeedImageViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
    }
    
    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.feed.isEmpty {
                self.feed = FeedImageViewModel.prototypeFeed
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageTableViewCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageTableViewCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
    
        let image = UIImage(named: model.imageName)
        fadeIn(image)
    }
}

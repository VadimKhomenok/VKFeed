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
    private let feed = FeedImageViewModel.prototypeFeed
    
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

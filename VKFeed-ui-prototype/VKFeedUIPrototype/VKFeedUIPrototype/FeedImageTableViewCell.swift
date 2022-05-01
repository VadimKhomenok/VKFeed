//
//  FeedImageTableViewCell.swift
//  VKFeedUIPrototype
//
//  Created by Vadim Khomenok on 2.05.22.
//

import UIKit

class FeedImageTableViewCell: UITableViewCell {
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setup(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        descriptionImageView.image = UIImage(named: model.imageName)
    }
}

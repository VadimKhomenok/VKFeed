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
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var feedImageContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
        feedImageContainerView.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
        feedImageContainerView.startShimmering()
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        UIView.animate(withDuration: 0.25, delay: 1.25, animations: {
            self.feedImageView.alpha = 1
        }, completion: { finished in
            self.feedImageContainerView.stopShimmering()
        })
    }
}

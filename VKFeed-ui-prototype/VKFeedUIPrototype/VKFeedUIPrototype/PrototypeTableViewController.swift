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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") ?? UITableViewCell()
    }
}

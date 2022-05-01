//
//  PrototypeTableViewController.swift
//  VKFeedUIPrototype
//
//  Created by Vadim Khomenok on 1.05.22.
//

import UIKit

class PrototypeTableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") ?? UITableViewCell()
    }
}

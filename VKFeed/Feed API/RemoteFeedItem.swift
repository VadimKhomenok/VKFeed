//
//  RemoteFeedItem.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 20.04.22.
//

import Foundation

struct RemoteFeedItem: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var image: URL
}

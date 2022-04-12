//
//  FeedItem.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

public struct FeedItem: Equatable {
    var id: UUID
    var description: String?
    var location: String?
    var imageUrl: URL
}

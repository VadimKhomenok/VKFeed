//
//  FeedItem.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

public struct FeedItem: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var imageUrl: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}

extension FeedItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageUrl = "image"
    }
}

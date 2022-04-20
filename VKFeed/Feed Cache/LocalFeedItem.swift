//
//  LocalFeedItem.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 20.04.22.
//

import Foundation

public struct LocalFeedItem: Equatable {
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

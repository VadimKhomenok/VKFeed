//
//  LocalFeedItem.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 20.04.22.
//

import Foundation

public struct LocalFeedImage: Equatable {
    public var id: UUID
    public var description: String?
    public var location: String?
    public var url: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}

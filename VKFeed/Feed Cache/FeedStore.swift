//
//  FeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.04.22.
//

import Foundation

public protocol FeedStore {
    typealias InsertionCompletion = (Error?) -> Void
    typealias DeletionCompletion = (Error?) -> Void
    
    func insert(items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCache(_ completion: @escaping DeletionCompletion)
}

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

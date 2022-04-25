//
//  CoreDataFeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData
import Foundation

private class ManagedCache: NSManagedObject {
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL?
    @NSManaged var cache: ManagedCache
}

public final class CoreDataFeedStore: FeedStore {
    public init() {}
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func deleteCache(_ completion: @escaping DeletionCompletion) {
        
    }
}

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
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}

private extension NSPersistentContainer {
    enum PersistentContainerError: Error {
        case modelNotExist
        case loadFailed(error: Error)
    }
    
    static func load(name: String, storeURL: URL, bundle: Bundle) throws -> NSPersistentContainer {
        guard let mom = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw PersistentContainerError.modelNotExist
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: mom)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        
        var loadPersistentStoresError: Error?
        container.loadPersistentStores { loadPersistentStoresError = $1 }
        try loadPersistentStoresError.map { throw PersistentContainerError.loadFailed(error: $0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

public final class CoreDataFeedStore: FeedStore {
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        self.persistentContainer = try NSPersistentContainer.load(name: "FeedStore", storeURL: storeURL, bundle: bundle)
        self.context = persistentContainer.newBackgroundContext()
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(nil)
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func deleteCache(_ completion: @escaping DeletionCompletion) {
        
    }
}

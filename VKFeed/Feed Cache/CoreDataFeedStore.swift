//
//  CoreDataFeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData
import Foundation

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var feed: NSOrderedSet
    @NSManaged var timestamp: Date
}

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
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
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.timestamp = timestamp
                managedCache.feed = NSOrderedSet(array: feed.map { local -> ManagedFeedImage in
                    let managedFeedImage = ManagedFeedImage(context: context)
                    managedFeedImage.id = local.id
                    managedFeedImage.imageDescription = local.description
                    managedFeedImage.location = local.location
                    managedFeedImage.url = local.url
                    return managedFeedImage
                })
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let context = context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                let results = try context.fetch(request).first
                if let cache = results {
                    let localFeed = cache.feed
                        .compactMap { $0 as? ManagedFeedImage }
                        .map {
                            LocalFeedImage(id: $0.id, description: $0.imageDescription, location: $0.location, url: $0.url)
                        }
                    
                    completion(.found(feed: localFeed, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
        
    public func deleteCache(_ completion: @escaping DeletionCompletion) {
        
    }
}

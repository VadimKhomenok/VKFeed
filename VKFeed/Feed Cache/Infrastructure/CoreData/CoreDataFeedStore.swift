//
//  CoreDataFeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData
import Foundation

public final class CoreDataFeedStore: FeedStore {

    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum PersistentStoreError: Error {
        case modelDoesNotExist
        case loadFailed(error: Error)
    }
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        guard let model = CoreDataFeedStore.model else {
            throw PersistentStoreError.modelDoesNotExist
        }
        
        do {
            self.persistentContainer = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, storeURL: storeURL)
            self.context = persistentContainer.newBackgroundContext()
        } catch {
            throw PersistentStoreError.loadFailed(error: error)
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success(.none))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
        
    public func deleteCache(_ completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}

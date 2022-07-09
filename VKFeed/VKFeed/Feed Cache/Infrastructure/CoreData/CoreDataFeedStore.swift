//
//  CoreDataFeedStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData
import Foundation

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let persistentContainer: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum PersistentStoreError: Error {
        case modelDoesNotExist
        case loadFailed(error: Error)
    }
    
    public init(storeURL: URL) throws {
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
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.persistentContainer.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    func performAsync(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    func performSync<R>(_ action: (NSManagedObjectContext) -> Result<R, Error>) throws -> R {
        let context = self.context
        var result: Result<R, Error>!
        context.performAndWait { result = action(context) }
        return try result.get()
    }
}

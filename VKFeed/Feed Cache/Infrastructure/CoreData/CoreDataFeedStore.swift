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
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}

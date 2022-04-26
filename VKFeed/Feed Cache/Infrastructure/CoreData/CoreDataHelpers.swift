//
//  CoreDataHelpers.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData

extension NSPersistentContainer {    
    static func load(name: String, model: NSManagedObjectModel, storeURL: URL) throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]
        
        var loadPersistentStoresError: Error?
        container.loadPersistentStores { loadPersistentStoresError = $1 }
        try loadPersistentStoresError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

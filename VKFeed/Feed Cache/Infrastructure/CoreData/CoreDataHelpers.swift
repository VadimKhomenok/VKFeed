//
//  CoreDataHelpers.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData

extension NSPersistentContainer {
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

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

//
//  ManagedCache.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var feed: NSOrderedSet
    @NSManaged var timestamp: Date
    
    var localFeed: [LocalFeedImage] {
        return feed.compactMap { ($0 as? ManagedFeedImage)?.local }
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<Self>(entityName: Self.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
}

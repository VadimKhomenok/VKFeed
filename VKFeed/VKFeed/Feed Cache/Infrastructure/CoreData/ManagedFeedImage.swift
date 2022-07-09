//
//  ManagedFeedImage.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.04.22.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        LocalFeedImage(id: self.id, description: self.imageDescription, location: self.location, url: self.url)
    }
    
    static func images(from localImages: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        let images = NSOrderedSet(array: localImages.map { local -> ManagedFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = local.id
            managedFeedImage.imageDescription = local.description
            managedFeedImage.location = local.location
            managedFeedImage.url = local.url
            managedFeedImage.data = context.userInfo[local.url] as? Data
            return managedFeedImage
        })
        
        context.userInfo.removeAllObjects()
        return images
    }
    
    static func data(with url: URL, in context: NSManagedObjectContext) throws -> Data? {
        if let cached = context.userInfo[url] as? Data { return cached }
        return try first(with: url, in: context)?.data
    }
    
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedImage? {
        let request = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    override func prepareForDeletion() {
        super.prepareForDeletion()
        managedObjectContext?.userInfo[url] = data
    }
}

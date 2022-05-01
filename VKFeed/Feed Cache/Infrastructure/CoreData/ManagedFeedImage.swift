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
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedImage {
    var local: LocalFeedImage {
        LocalFeedImage(id: self.id, description: self.imageDescription, location: self.location, url: self.url)
    }
    
    static func images(from localImages: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localImages.map { local -> ManagedFeedImage in
            let managedFeedImage = ManagedFeedImage(context: context)
            managedFeedImage.id = local.id
            managedFeedImage.imageDescription = local.description
            managedFeedImage.location = local.location
            managedFeedImage.url = local.url
            return managedFeedImage
        })
    }
}

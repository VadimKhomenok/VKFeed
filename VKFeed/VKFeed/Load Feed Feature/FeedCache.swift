//
//  FeedCache.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}

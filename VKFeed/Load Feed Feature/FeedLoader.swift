//
//  FeedLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

enum FeedLoaderResult {
    case success(feed: [FeedItem])
    case failure(error: Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (FeedLoaderResult) -> Void)
}

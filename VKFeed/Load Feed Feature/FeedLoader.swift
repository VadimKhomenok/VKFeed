//
//  FeedLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

public typealias FeedLoaderResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}

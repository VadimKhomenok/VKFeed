//
//  FeedLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

public enum FeedLoaderResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension FeedLoaderResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func loadFeed(completion: @escaping (FeedLoaderResult<Error>) -> Void)
}

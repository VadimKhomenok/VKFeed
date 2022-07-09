//
//  FeedImageDataCache.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation

public protocol FeedImageDataCache {
    func save(_ data: Data, for url: URL) throws
}

//
//  FeedImageDataStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 31.05.22.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ imageData: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}

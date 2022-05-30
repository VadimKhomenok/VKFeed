//
//  FeedImageDataStore.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 31.05.22.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

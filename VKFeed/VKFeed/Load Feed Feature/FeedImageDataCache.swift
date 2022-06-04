//
//  FeedImageDataCache.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation

public protocol FeedImageDataCache {
    typealias SaveResult = Result<Void, Swift.Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

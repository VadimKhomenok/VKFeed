//
//  FeedLoaderStub.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import VKFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(self.result)
    }
}

//
//  RemoteFeedLoaderWithCacheSaveDecorator.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 4.06.22.
//

import Foundation
import VKFeed

class RemoteFeedLoaderWithCacheSaveDecorator: FeedLoader {
    private let remote: RemoteFeedLoader
    private let local: LocalFeedLoader
    
    init(remote: RemoteFeedLoader, local: LocalFeedLoader) {
        self.remote = remote
        self.local = local
    }
    
    func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        remote.load { [weak self] result in
            switch result {
            case let .success(loadedFeed):
                self?.local.save(loadedFeed) { _ in }
                
            default:
                break
            }
            
            completion(result)
        }
    }
}

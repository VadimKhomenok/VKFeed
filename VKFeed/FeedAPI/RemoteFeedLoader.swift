//
//  RemoteFeedLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 11.04.22.
//

import Foundation

public class RemoteFeedLoader {
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(_):
                completion(.failure(.invalidData))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
}

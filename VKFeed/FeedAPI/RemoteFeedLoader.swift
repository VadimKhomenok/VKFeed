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
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data, let response):
                completion(self.map(data, from: response))
            case .failure(_):
                completion(.failure(.connectivity))
            }
        }
    }
    
    func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        if let feedItems = try? FeedItemsMapper.map(data, response) {
            return .success(feedItems)
        } else {
            return .failure(.invalidData)
        }
    }
}

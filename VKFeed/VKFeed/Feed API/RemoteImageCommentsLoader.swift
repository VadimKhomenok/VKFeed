//
//  RemoteImageCommentsLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

public class RemoteImageCommentsLoader {
    private var client: HTTPClient
    private var url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<[ImageComment], Swift.Error>
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(Self.map(data: data, response: response))
            case .failure(_):
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let remoteComments = try RemoteImageCommentsMapper.map(data, from: response)
            return .success(remoteComments)
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}

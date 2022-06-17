//
//  FeedItemsMapper.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 12.04.22.
//

import Foundation

public final class FeedItemsMapper {
    private struct FeedItemsWrapper: Decodable {
        private let items: [RemoteFeedItem]
        
        private struct RemoteFeedItem: Decodable {
            var id: UUID
            var description: String?
            var location: String?
            var image: URL
        }
        
        var feed: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK, let wrapper = try? JSONDecoder().decode(FeedItemsWrapper.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
         
        return wrapper.feed
    }
}

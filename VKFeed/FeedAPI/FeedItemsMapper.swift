//
//  FeedItemsMapper.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 12.04.22.
//

import Foundation

internal final class FeedItemsMapper {
    private struct FeedItemsWrapper: Decodable {
        var items: [Item]
        
        var feedItems: [FeedItem] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
    
    private static let OK_200 = 200

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let wrapper = try? JSONDecoder().decode(FeedItemsWrapper.self, from: data) else {
            return .failure(.invalidData)
        }
         
        return .success(wrapper.feedItems)
    }
}

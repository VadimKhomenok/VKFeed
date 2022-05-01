//
//  FeedItemsMapper.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 12.04.22.
//

import Foundation

final class FeedItemsMapper {
    private struct FeedItemsWrapper: Decodable {
        var items: [RemoteFeedItem]
    }
    
    private static let OK_200 = 200

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let wrapper = try? JSONDecoder().decode(FeedItemsWrapper.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
         
        return wrapper.items
    }
}

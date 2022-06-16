//
//  RemoteImageCommentsMapper.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

final class RemoteImageCommentsMapper {
    private struct FeedItemsWrapper: Decodable {
        var items: [RemoteFeedItem]
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let wrapper = try? JSONDecoder().decode(FeedItemsWrapper.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
         
        return wrapper.items
    }
}

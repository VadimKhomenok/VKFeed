//
//  RemoteImageCommentsLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: RemoteImageCommentsMapper.map)
    }
}

//
//  FeedEndpoint.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 1.07.22.
//

public enum FeedEndpoint {
    case get
    
    public func url(baseUrl: URL) -> URL {
        switch self {
        case .get:
            return baseUrl.appendingPathComponent("/v1/feed")
        }
    }
}

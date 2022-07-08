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
            var components = URLComponents()
            components.scheme = baseUrl.scheme
            components.host = baseUrl.host
            components.path = baseUrl.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            return components.url!
        }
    }
}

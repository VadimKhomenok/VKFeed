//
//  ImageCommentsEndpoint.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 1.07.22.
//

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseUrl: URL) -> URL {
        switch self {
        case let .get(id):
            return baseUrl.appendingPathComponent("/v1/image/\(id)/comments")
        }
    }
}

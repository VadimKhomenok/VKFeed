//
//  RemoteImageCommentsMapper.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

public final class RemoteImageCommentsMapper {
    private struct Root: Decodable {
        private let items: [RemoteImageComments]
        
        private struct RemoteImageComments: Decodable {
            public let id: UUID
            public let message: String
            public let created_at: Date
            public let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username )}
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOK(response), let wrapper = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
         
        return wrapper.comments
    }
    
    private static func isOK(_ urlResponse: HTTPURLResponse) -> Bool {
        return (200...299).contains(urlResponse.statusCode)
    }
}

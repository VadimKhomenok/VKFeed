//
//  RemoteImageCommentsMapperTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 16.06.22.
//

import XCTest
import VKFeed

class RemoteImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxStatusResponse() throws {
        let codes = [150, 199, 300, 400, 500]
        let jsonData = makeItemsJson([])
        
        try codes.forEach { code in
            XCTAssertThrowsError(
                try RemoteImageCommentsMapper.map(jsonData, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxStatusCodeWithInvalidJson() throws {
        let codes = [200, 201, 240, 290, 299]
        let invalidJson = Data("invalid json".utf8)
        
        try codes.forEach { code in
            XCTAssertThrowsError(
                try RemoteImageCommentsMapper.map(invalidJson, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxStatusCodeWithEmptyJson() throws {
        let codes = [200, 201, 240, 290, 299]

        try codes.forEach { code in
            let emptyJson = makeItemsJson([])
            let result = try RemoteImageCommentsMapper.map(emptyJson, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_load_deliversFeedItemsOn200StatusCodeWithItemsJson() throws {
        let codes = [200, 201, 240, 290, 299]
        
        let (item1, item1Json) = makeItem(
            id: UUID(),
            message: "a comment",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "User 1")
        
        let (item2, item2Json) = makeItem(
            id: UUID(),
            message: "another comment",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "User 2")
        
        let itemsJsonData = makeItemsJson([item1Json, item2Json])
        
        try codes.forEach { code in
            let result = try RemoteImageCommentsMapper.map(itemsJsonData, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1, item2])
        }
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), username: String) -> (ImageComment, [String : Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        
        let itemJson: [String : Any] = [
            "id" : id.uuidString,
            "message" : message,
            "created_at" : createdAt.iso8601String,
            "author" : [
                "username" : username
            ]
        ]
        
        return (item, itemJson)
    }
}

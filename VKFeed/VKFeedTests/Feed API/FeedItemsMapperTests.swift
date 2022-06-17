//
//  FeedItemsMapperTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 11.04.22.
//

import XCTest
import VKFeed

class FeedItemsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200StatusResponse() throws {
        let codes = [199, 201, 300, 400, 500]
        let jsonData = makeItemsJson([])
        
        try codes.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(jsonData, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200StatusCodeWithInvalidJson() throws {
        let invalidJson = Data("invalid json".utf8)
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJson, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200StatusCodeWithEmptyJson() throws {
        let emptyJson = makeItemsJson([])
        
        let result = try FeedItemsMapper.map(emptyJson, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversFeedItemsOn200StatusCodeWithItemsJson() throws {
        let (item1, item1Json) = makeItem(id: UUID(), imageUrl: URL(string: "https://url.com")!)
        let (item2, item2Json) = makeItem(id: UUID(), description: "a description", location: "a location", imageUrl: URL(string: "https://another-url.com")!)
        let itemsJsonData = makeItemsJson([item1Json, item2Json])
        
        let result = try FeedItemsMapper.map(itemsJsonData, from: HTTPURLResponse(statusCode: 200))
        XCTAssertEqual(result, [item1, item2])
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (FeedImage, [String : Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageUrl)
        
        let itemJson = [
            "id" : item.id.uuidString,
            "description" : item.description,
            "location" : item.location,
            "image" : item.url.absoluteString
        ].compactMapValues { $0 }
        
        return (item, itemJson)
    }
}

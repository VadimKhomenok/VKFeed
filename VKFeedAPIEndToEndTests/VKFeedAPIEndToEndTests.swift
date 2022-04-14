//
//  VKFeedAPIEndToEndTests.swift
//  VKFeedAPIEndToEndTests
//
//  Created by Vadim Khomenok on 15.04.22.
//

import XCTest
import VKFeed

class VKFeedAPIEndToEndTests: XCTestCase {
    func test_getFeedItems_matchesFixedData() {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        var receivedItems: [FeedItem]?
        let expectation = expectation(description: "Wait for completion to finish")
        sut.load { result in
            switch result {
            case let .success(items):
                receivedItems = items
            case let .failure(error):
                XCTFail("Expected feed items but received failure with \(error)")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(receivedItems?.count, 8)
        XCTAssertEqual(receivedItems?[0], expectedFeedItem(at: 0))
        XCTAssertEqual(receivedItems?[1], expectedFeedItem(at: 1))
        XCTAssertEqual(receivedItems?[2], expectedFeedItem(at: 2))
        XCTAssertEqual(receivedItems?[3], expectedFeedItem(at: 3))
        XCTAssertEqual(receivedItems?[4], expectedFeedItem(at: 4))
        XCTAssertEqual(receivedItems?[5], expectedFeedItem(at: 5))
        XCTAssertEqual(receivedItems?[6], expectedFeedItem(at: 6))
        XCTAssertEqual(receivedItems?[7], expectedFeedItem(at: 7))
    }
    
// MARK: - Helpers
    
    private func expectedFeedItem(at index: Int) -> FeedItem {
        return FeedItem(id: id(at: index), description: description(at: index), location: location(at: index), imageUrl: imageURL(at: index))
    }
    
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
}

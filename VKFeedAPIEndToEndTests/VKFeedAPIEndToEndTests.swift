//
//  VKFeedAPIEndToEndTests.swift
//  VKFeedAPIEndToEndTests
//
//  Created by Vadim Khomenok on 15.04.22.
//

import XCTest
import VKFeed

#warning("In tutorial he adds questionmark to cases of optional result - f.e. 'case let .success(imageFeed)?' or 'case let .failure(error)?' - I'm not sure if it is necessary, seems to work in the same way in both scenarios")

class VKFeedAPIEndToEndTests: XCTestCase {
    func test_getFeedImages_matchesFixedData() {
        switch getFeedResult() {
        case let .success(imageFeed):
            XCTAssertEqual(imageFeed.count, 8)
            XCTAssertEqual(imageFeed[0], expectedFeedImage(at: 0))
            XCTAssertEqual(imageFeed[1], expectedFeedImage(at: 1))
            XCTAssertEqual(imageFeed[2], expectedFeedImage(at: 2))
            XCTAssertEqual(imageFeed[3], expectedFeedImage(at: 3))
            XCTAssertEqual(imageFeed[4], expectedFeedImage(at: 4))
            XCTAssertEqual(imageFeed[5], expectedFeedImage(at: 5))
            XCTAssertEqual(imageFeed[6], expectedFeedImage(at: 6))
            XCTAssertEqual(imageFeed[7], expectedFeedImage(at: 7))
        case let .failure(error):
            XCTFail("Expected feed images but received failure with \(error)")
        default:
            XCTFail("Expected feed images but no result received")
        }
    }
    
// MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        var receivedResult: FeedLoader.Result?
        let expectation = expectation(description: "Wait for completion to finish")
        sut.load { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedFeedImage(at index: Int) -> FeedImage {
        return FeedImage(id: id(at: index), description: description(at: index), location: location(at: index), url: imageURL(at: index))
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

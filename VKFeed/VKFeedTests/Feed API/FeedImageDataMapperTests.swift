//
//  FeedImageDataMapperTests.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed
import XCTest

class FeedImageDataMapperTests: XCTestCase {
    
    func test_map_throwsInvalidDataErrorOnNon200StatusCodeResponse() throws {
        let codes = [199, 201, 300, 400, 500]
        let data = "Any data".data(using: .utf8)!
        
        try codes.forEach { code in
            XCTAssertThrowsError(
                try FeedImageDataMapper.map(data, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200WithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversReceivedNonEmptyDataOn200Success() throws {
        let anyData = anyData()
        
        let result = try FeedImageDataMapper.map(anyData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, anyData)
    }
}

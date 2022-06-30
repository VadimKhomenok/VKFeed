//
//  ImageCommentsEndpointTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 1.07.22.
//

import XCTest
import VKFeed

class ImageCommentsEndpointTests: XCTestCase {
    
    func test_imageComments_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        let imageID = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        
        let resultUrl = ImageCommentsEndpoint.get(imageID).url(baseUrl: baseURL)
        let expectedUrl = URL(string: "http://base-url.com/v1/image/2239CBA2-CB35-4392-ADC0-24A37D38E010/comments")!
        
        XCTAssertEqual(resultUrl, expectedUrl)
    }
}

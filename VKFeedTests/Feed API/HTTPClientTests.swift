//
//  HTTPClientTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 13.04.22.
//

import Foundation
import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping () -> Void = {}) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromUrl_createsDataTaskWithProperUrl() {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "https://api-url.com")!
        
        sut.get(from: url)

        XCTAssertEqual(session.capturedUrls, [url])
    }
    
    class URLSessionSpy: URLSession {
        var capturedUrls = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            capturedUrls.append(url)
            return URLSessionDataTaskTest()
        }
    }
    
    class URLSessionDataTaskTest: URLSessionDataTask {}
}

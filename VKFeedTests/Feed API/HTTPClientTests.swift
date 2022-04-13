//
//  HTTPClientTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 13.04.22.
//

import Foundation
import XCTest

// why we need to specifically override resume() method in FakeURLSessionDataTask? Shouldn't it be inherited and be called by default in superclass?

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping () -> Void = {}) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromUrl_resumesDataTask() {
        let url = URL(string: "https://api-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(task: task, for: url)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)

        XCTAssertEqual(task.resumeCount, 1)
    }
    
    class URLSessionSpy: URLSession {
        private var stubbedTasks = [URL : URLSessionDataTask]()
        
        func stub(task: URLSessionDataTask, for url: URL) {
            stubbedTasks[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubbedTasks[url] ?? FakeURLSessionDataTask()
        }
    }
    
    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCount: Int = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
}

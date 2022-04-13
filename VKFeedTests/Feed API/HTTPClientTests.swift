//
//  HTTPClientTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 13.04.22.
//

import Foundation
import XCTest
import VKFeed

// why we need to specifically override resume() method in FakeURLSessionDataTask? Shouldn't it be inherited and be called by default in superclass?

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromUrl_resumesDataTask() {
        let url = URL(string: "https://api-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(task: task, for: url)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { result in
            
        }

        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_getFromUrl_failsOnDataTaskError() {
        let url = URL(string: "https://api-url.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "An error", code: 400)
        
        session.stub(error: error, for: url)

        let sut = URLSessionHTTPClient(session: session)

        let expectation = expectation(description: "Wait for completion closure to end")
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure result, but received something else")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

    
// MARK: - Helpers
    
    class URLSessionSpy: URLSession {
        private var stubs = [URL : Stub]()
        
        struct Stub {
            var task: URLSessionDataTask
            var error: Error?
        }
        
        func stub(task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil, for url: URL) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("No stub is available for provided URL \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
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

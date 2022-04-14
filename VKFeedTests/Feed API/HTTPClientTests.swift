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
    
    init(session: URLSession = .shared) {
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
//    func test_getFromUrl_resumesDataTask() {
//        let url = URL(string: "https://api-url.com")!
//        let task = URLSessionDataTaskSpy()
//        session.stub(task: task, for: url)
//
//        let sut = URLSessionHTTPClient(session: URLSession.shared)
//
//        sut.get(from: url) { result in
//
//        }
//
//        XCTAssertEqual(task.resumeCount, 1)
//    }
    
    func test_getFromUrl_failsOnDataTaskError() {
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "https://api-url.com")!
        let error = NSError(domain: "An error", code: 400)
    
        URLProtocolStub.stub(error: error, url: url)

        let sut = URLSessionHTTPClient()

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
        URLProtocolStub.stopInterceptingRequests()
    }

    
// MARK: - Helpers

    class URLProtocolStub: URLProtocol {
        private static var stubs = [URL : Stub]()
        
        private struct Stub {
            var error: Error?
        }
        
        class func stub(error: Error, url: URL) {
            stubs[url] = Stub(error: error)
        }
        
        // MARK: - Helper methods
        
        class func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        class func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stubs = [:]
        }
        
        // MARK: - Overridden methods of URLProtocol
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            return (stubs[url] != nil)
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

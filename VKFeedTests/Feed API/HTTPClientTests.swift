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
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromUrl_requestHasProperUrlAndMethod() {
        let url = anyURL()
        let expectation = expectation(description: "Wait for request interception")
        
        URLProtocolStub.captureRequestClosure = { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            expectation.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromUrl_failsOnDataTaskError() {
        let error = NSError(domain: "An error", code: 400)
    
        URLProtocolStub.stub(data: nil, response: nil, error: error)

        let expectation = expectation(description: "Wait for completion closure to end")
        makeSUT().get(from: anyURL()) { result in
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
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func anyURL() -> URL {
        return URL(string: "https://api-url.com")!
    }
    
    
// MARK: - Stubs

    class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        static var captureRequestClosure: ((URLRequest) -> Void)?
        
        private struct Stub {
            var data: Data?
            var response: HTTPURLResponse?
            var error: Error?
        }
        
        class func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        // MARK: - Helper methods
        
        class func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        class func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            URLProtocolStub.stub = nil
        }
        
        // MARK: - Overridden methods of URLProtocol
        
        override class func canInit(with request: URLRequest) -> Bool {
            captureRequestClosure?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

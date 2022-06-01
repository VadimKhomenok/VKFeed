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

class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
    }
    
    func test_getFromUrl_requestHasProperUrlAndMethod() {
        let url = anyURL()
        let expectation = expectation(description: "Wait for request interception")
        
        URLProtocolStub.observeRequest() { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_getFromUrl_failsOnDataTaskError() {
        let error = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: error))
        
        XCTAssertEqual((receivedError as NSError?)?.domain, error.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, error.code)
    }

    func test_getFromUrl_failsOnAllInvalidCombinationsOfResults() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyNonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyNonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyNonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: normalHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyNonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: normalHTTPURLResponse(), error: anyNSError())))
    }
    
    func test_getFromUrl_successWithValidDataAndResponseOnRequestWithValidData() {
        let anyData = anyData()
        let httpUrlResponse = normalHTTPURLResponse()
        let receivedValues = resultValuesFor((data: anyData, response: httpUrlResponse, error: nil))
        
        XCTAssertEqual(receivedValues?.data, anyData)
        XCTAssertEqual(receivedValues?.response.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpUrlResponse.statusCode)
    }
    
    func test_getFromUrl_successWithEmptyDataAndValidResponseOnRequestWithNilData() {
        let httpUrlResponse = normalHTTPURLResponse()
        let receivedValues = resultValuesFor((data: nil, response: httpUrlResponse, error: nil))

        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.response.statusCode, httpUrlResponse.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor { $0.cancel() } as? NSError
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    

// MARK: - Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func anyNonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func normalHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        let expectation = expectation(description: "Wait for completion to execute")
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
    
    func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected data and response but received something else", file: file, line: line)
        }
        
        return nil
    }
    
    func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected error but received something else", file: file, line: line)
        }
        
        return nil
    }
}

//
//  HTTPClientSpy.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 25.05.22.
//

import VKFeed

class HTTPClientSpy: HTTPClient {
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        messages.append((url: url, completion: completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
        
        messages[index].completion(.success((data, response)))
    }
}

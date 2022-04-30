//
//  URLSessionHTTPClient.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 14.04.22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnspecifiedError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                completion(.failure(error ?? UnspecifiedError()))
                return
            }
            completion(.success((data, response)))
        }.resume()
    }
}

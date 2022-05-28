//
//  RemoteFeedImageDataLoader.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 28.05.22.
//

import Foundation

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private var client: HTTPClient
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        var wrapped: HTTPClientTask?
        
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: ((FeedImageDataLoader.Result) -> Void)?) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        
        return task
    }
}

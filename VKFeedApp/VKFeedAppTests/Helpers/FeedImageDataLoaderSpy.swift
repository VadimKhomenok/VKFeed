//
//  FeedImageDataLoaderSpy.swift
//  VKFeedAppTests
//
//  Created by Vadim Khomenok on 4.06.22.
//

import VKFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        var cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
}

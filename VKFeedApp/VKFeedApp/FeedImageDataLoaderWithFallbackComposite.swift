//
//  FeedImageDataLoaderWithFallbackComposite.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 4.06.22.
//

import VKFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    private let fallback: FeedImageDataLoader

    #warning("I don't understand why it is necessary to have wrapper for task here instead of using the task which is returned by the FeedImageDataLoader which is absolutely the same. Wrapper makes sense in URLSessionHTTPClient because we don't want the details of URLSession client implementation to leak further, that's why we create a wrapper which contains the task produced by URLSession, but clients of URLSessionHTTPClient won't know about URLSession task and will use an interface which is provided by URLSessionHTTPClient. It makes sense, URLSession tasks differs a lot from the HTTPClientTask protocol and contains many properties and functions which client should not need. But why here? In this class both the wrapper and the task returned by the FeedImageDataLoader are very simple, share the same protocol. Also client anyway knows about FeedImageDataLoader and therefore it makes no sense to hide task of it. Looks like an unnecessary complication unless it was implemented this way to prevent future cases when FeedImageDataLoaderTask may become different")
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case .success:
                completion(result)
                
            case .failure:
                task.wrapped = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        
        return task
    }
}

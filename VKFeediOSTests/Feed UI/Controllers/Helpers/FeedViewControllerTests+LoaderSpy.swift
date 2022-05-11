//
//  FeedViewControllerTests+LoaderSpy.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import VKFeediOS

extension FeedViewControllerTests {
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - Feed Loader Spy
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(feed: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoading(with error: Error, at index: Int) {
            feedRequests[index](.failure(error))
        }
        
        // MARK: - Feed Image Loader Spy
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            var cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        var loadedImageUrls: [URL] {
            imageRequests.map { $0.url }
        }
        
        var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        var cancelledRequestedUrls = [URL]()
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledRequestedUrls.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            imageRequests[index].completion(.failure(anyNSError()))
        }
    }
}

//
//  FeedViewControllerTests+LoaderSpy.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import VKFeediOS
import Combine

extension FeedUIIntegrationTests {
    
    class LoaderSpy {
        
        // MARK: - Feed Loader Spy
        
        private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Swift.Error>]()
        
        var loadFeedCallCount: Int {
            feedRequests.count
        }
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Swift.Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Swift.Error>()
            feedRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(feed: [FeedImage] = [], at index: Int) {
            feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
            }))
            feedRequests[index].send(completion: .finished)
        }
        
        func completeFeedLoading(with error: Error, at index: Int) {
            feedRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - Load More
        
        private var loadMoreRequests = [PassthroughSubject<Paginated<FeedImage>, Swift.Error>]()
        
        var loadMoreCallCount: Int {
            loadMoreRequests.count
        }
        
        func loadMorePublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            loadMoreRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int) {
            loadMoreRequests[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    self?.loadMorePublisher() ?? Empty().eraseToAnyPublisher()
                }))
        }
        
        func completeLoadMore(with error: Error, at index: Int) {
            loadMoreRequests[index].send(completion: .failure(error))
        }
        
        // MARK: - Feed Image Loader Spy
        
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        var loadedImageUrls: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }
        
        func completeImageLoadingWithError(at index: Int) {
            imageRequests[index].publisher.send(completion: .failure(anyNSError()))
        }
    }
}

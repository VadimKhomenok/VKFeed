//
//  FeedImageViewModel.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 14.05.22.
//

import VKFeed

final class FeedImageViewModel<Image> {
    
    typealias Observer<T> = (T) -> Void
    
    private let feedModel: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    var imageTransformer: (Data) -> Image?
    
    var description: String? { feedModel.description }
    var location: String? { feedModel.location }
    var isLocationHidden: Bool { feedModel.location == nil }
    var isDescriptionHidden: Bool { feedModel.description == nil }
    
    init(imageLoader: FeedImageDataLoader, feedModel: FeedImage, imageTransformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.feedModel = feedModel
        self.imageTransformer = imageTransformer
    }
    
    func loadImage() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: feedModel.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            self.onImageLoad?(image)
        } else {
            self.onShouldRetryImageLoadStateChange?(true)
        }
        self.onImageLoadingStateChange?(false)
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
    }
}

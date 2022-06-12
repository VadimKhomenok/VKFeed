//
//  FeedImageDataLoaderPresentationAdapter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 18.05.22.
//

import VKFeed
import VKFeediOS
import Combine

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    var presenter: FeedImagePresenter<View, Image>?
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    init(model: FeedImage, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = loader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        
        cancellable = imageLoader(model.url)
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished: break
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        } receiveValue: { [weak self] data in
            self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        }
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}

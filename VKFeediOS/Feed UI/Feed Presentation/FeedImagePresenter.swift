//
//  FeedImagePresenter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 15.05.22.
//

import VKFeed
import UIKit

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewData<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    var view: View
    var imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: true,
            isRetry: false,
            image: nil))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: false,
            image: image))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewData(
            description: model.description,
            location: model.location,
            isLoading: false,
            isRetry: true,
            image: nil))
    }
}

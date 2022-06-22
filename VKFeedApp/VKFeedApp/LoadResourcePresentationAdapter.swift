//
//  FeedLoaderPresentationAdapter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 18.05.22.
//

import VKFeed
import VKFeediOS
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    var presenter: LoadResourcePresenter<Resource, View>?
    private let loader: () -> AnyPublisher<Resource, Swift.Error>
    
    private var cancellable: Cancellable?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Swift.Error>) {
        self.loader = loader
    }

    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
                
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak self] resource in
            self?.presenter?.didFinishLoading(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: ListViewControllerDelegate {
    func didRequestRefresh() {
        loadResource()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}

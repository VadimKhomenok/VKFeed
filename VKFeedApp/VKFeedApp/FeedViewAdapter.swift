//
//  FeedViewAdapter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 18.05.22.
//

import UIKit
import VKFeed
import VKFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(feedViewController: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = feedViewController
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [loader] in
                loader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(object: view),
                resourceView: WeakRefVirtualProxy(object: view),
                resourceLoadErrorView: WeakRefVirtualProxy(object: view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageDataError()
                    }
                    
                    return image
                })
            
            return view
        })
    }
}

private struct InvalidImageDataError: Error {}

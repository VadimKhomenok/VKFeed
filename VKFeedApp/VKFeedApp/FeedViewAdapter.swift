//
//  FeedViewAdapter.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 18.05.22.
//

import UIKit
import VKFeed
import VKFeediOS

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(feedViewController: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = feedViewController
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, loader: loader)
            let view = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(object: view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}

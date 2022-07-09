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
    private weak var controller: ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void
    private let currentFeed: [FeedImage: CellController]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(currentFeed: [FeedImage: CellController] = [:], feedViewController: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.currentFeed = currentFeed
        self.controller = feedViewController
        self.loader = loader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        guard let controller = controller else {
            return
        }
        
        var currentFeed = self.currentFeed
        let feedControllers: [CellController] = viewModel.items.map { model in
            if let controller = self.currentFeed[model] {
                return controller
            }
            
            let adapter = ImageDataPresentationAdapter(loader: { [loader] in
                loader(model.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in
                    selection(model)
                })
            
            adapter.presenter = LoadResourcePresenter(
                loadingView: WeakRefVirtualProxy(object: view),
                resourceView: WeakRefVirtualProxy(object: view),
                resourceLoadErrorView: WeakRefVirtualProxy(object: view),
                mapper: UIImage.tryMake)
            
            let controller = CellController(id: model, view)
            currentFeed[model] = controller
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feedControllers)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: loadMore),
            resourceView: FeedViewAdapter(
                currentFeed: currentFeed,
                feedViewController: controller,
                loader: loader,
                selection: selection),
            resourceLoadErrorView: WeakRefVirtualProxy(object: loadMore),
            mapper: { $0 })
        
        let loadMoreSection = CellController(id: UUID(), loadMore)

        controller.display(feedControllers, [loadMoreSection])
    }
}

extension UIImage {
    struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        
        return image
    }
}

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
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(feedViewController: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher, selection: @escaping (FeedImage) -> Void) {
        self.controller = feedViewController
        self.loader = loader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feedControllers: [CellController] = viewModel.items.map { model in
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
            
            return CellController(id: model, view)
        }
        
        let loadMore = CellController(id: UUID(), LoadMoreCellController {
            viewModel.loadMore?({ _ in })
        })
        
        controller?.display(feedControllers, [loadMore])
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

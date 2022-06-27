//
//  CommentsUIComposer.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 27.06.22.
//

import VKFeed
import VKFeediOS
import UIKit
import Combine

public final class CommentsUIComposer {
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        
        let feedViewController = makeWith(title: ImageCommentsPresenter.title)
        feedViewController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: feedViewController),
            resourceView: CommentsViewAdapter(commentsViewController: feedViewController),
            resourceLoadErrorView: WeakRefVirtualProxy(object: feedViewController),
            mapper: { ImageCommentsPresenter.map(comments: $0) })
        
        presentationAdapter.presenter = presenter
        return feedViewController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let commentsViewController = storyboard.instantiateInitialViewController() as! ListViewController
        commentsViewController.title = title
        
        return commentsViewController
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(commentsViewController: ListViewController) {
        self.controller = commentsViewController
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(
            viewModel.comments.map { commentModel in
                CellController(id: commentModel, ImageCommentCellController(model: commentModel))
            }
        )
    }
}

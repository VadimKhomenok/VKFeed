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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
        
        let feedViewController = makeWith(title: FeedPresenter.title)
        feedViewController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: feedViewController),
            resourceView: FeedViewAdapter(
                feedViewController: feedViewController,
                loader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
            resourceLoadErrorView: WeakRefVirtualProxy(object: feedViewController),
            mapper: FeedPresenter.map)
        
        presentationAdapter.presenter = presenter
        return feedViewController
    }
    
    private static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! ListViewController
        feedViewController.title = title
        
        return feedViewController
    }
}

//
//  FeedUIComposer.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import VKFeediOS
import UIKit
import Combine

public final class FeedUIComposer {
    private init() {}
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        selection: @escaping (FeedImage) -> Void
    ) -> ListViewController {
        let presentationAdapter = FeedPresentationAdapter(loader: feedLoader)
        
        let feedViewController = makeWith(title: FeedPresenter.title)
        feedViewController.onRefresh = presentationAdapter.loadResource
        
        let presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: feedViewController),
            resourceView: FeedViewAdapter(
                feedViewController: feedViewController,
                loader: imageLoader,
                selection: selection),
            resourceLoadErrorView: WeakRefVirtualProxy(object: feedViewController))
        
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

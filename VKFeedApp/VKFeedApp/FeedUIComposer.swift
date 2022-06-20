//
//  FeedUIComposer.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 11.05.22.
//

import VKFeed
import VKFeediOS
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, feedLoader: @escaping () -> LocalFeedLoader.Publisher) -> FeedViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: feedLoader)
        
        let feedViewController = makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        let presenter = LoadResourcePresenter(
            loadingView: WeakRefVirtualProxy(object: feedViewController),
            resourceView: FeedViewAdapter(
                feedViewController: feedViewController,
                loader: imageLoader),
            resourceLoadErrorView: WeakRefVirtualProxy(object: feedViewController),
            mapper: FeedPresenter.map)
        
        presentationAdapter.presenter = presenter
        return feedViewController
    }
    
    private static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title
        
        return feedViewController
    }
}

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
    
    public static func feedComposedWith(imageLoader: FeedImageDataLoader, feedLoader: FeedLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let feedViewController = makeWith(
            delegate: presentationAdapter,
            title: FeedPresenter.title)
        
        let presenter = FeedPresenter(feedLoadingView: WeakRefVirtualProxy(object: feedViewController), feedView: FeedViewAdapter(feedViewController: feedViewController, loader: MainQueueDispatchDecorator(decoratee: imageLoader)), feedErrorView: WeakRefVirtualProxy(object: feedViewController))
        presentationAdapter.presenter = presenter
        return feedViewController
    }
    
    private static func makeWith(delegate: FeedLoaderPresentationAdapter, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title
        
        return feedViewController
    }
}

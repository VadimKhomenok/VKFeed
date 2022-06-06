//
//  SceneDelegate.swift
//  VKFeedApp
//
//  Created by Vadim Khomenok on 2.06.22.
//

import UIKit
import VKFeediOS
import VKFeed
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("FeedStore.sqlite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        configureScene()
    }
    
    func configureScene() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let feedStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: feedStore, currentDate: Date.init)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: feedStore)
        
        window?.rootViewController = UINavigationController(rootViewController:
            FeedUIComposer.feedComposedWith(
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localFeedImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteFeedImageLoader,
                    cache: localFeedImageLoader)),
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader)))
        
        window?.makeKeyAndVisible()
    }
    
    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}


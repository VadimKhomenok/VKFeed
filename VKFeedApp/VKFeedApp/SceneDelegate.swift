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
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var httpClient: HTTPClient = {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent("FeedStore.sqlite"))
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        configureScene()
    }
    
    func configureScene() {
        window?.rootViewController = UINavigationController(rootViewController:
            FeedUIComposer.feedComposedWith(
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            feedLoader: makeRemoteFeedLoaderWithLocalFallback))
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .cache(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
        let remoteFeedImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localFeedImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localFeedImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteFeedImageLoader
                    .loadImageDataPublisher(from: url)
                    .cache(to: localFeedImageLoader, using: url)
            })
    }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}

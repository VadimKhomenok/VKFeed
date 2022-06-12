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
import Combine

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
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: httpClient)
        
        return remoteFeedLoader
            .loadPublisher()
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

public extension FeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Swift.Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Error>
    
    func loadImageDataPublisher(from url: URL) -> Publisher {
        var task: FeedImageDataLoaderTask?
        
        return Deferred {
            Future { completion in
                task = loadImageData(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func cache(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: cache.saveIgnoringResult)
            .eraseToAnyPublisher()
    }
}

private extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}

extension Publisher where Output == Data {
    func cache(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: { data in
            cache.saveIgnoringResult(data, for: url)
        })
        .eraseToAnyPublisher()
    }
}

private extension FeedImageDataCache {
    func saveIgnoringResult(_ data: Data, for url: URL) {
        save(data, for: url) { _ in }
    }
}

extension Publisher {
    func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler)
            .eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
          ImmediateWhenOnMainQueueScheduler()
      }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
             DispatchQueue.main.now
         }

         var minimumTolerance: SchedulerTimeType.Stride {
             DispatchQueue.main.minimumTolerance
         }

         func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
             guard Thread.isMainThread else {
                 return DispatchQueue.main.schedule(options: options, action)
             }

             action()
         }

         func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
             DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
         }

         func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
             DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
         }
    }
}

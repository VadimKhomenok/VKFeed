//
//  LoadResourcePresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 18.06.22.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public struct ResourceLoadingViewModel {
    public var isLoading: Bool
}

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceLoadErrorViewModel {
        return ResourceLoadErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> ResourceLoadErrorViewModel {
        ResourceLoadErrorViewModel(message: message)
    }
}

public protocol ResourceLoadErrorView {
    func display(_ viewModel: ResourceLoadErrorViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceLoadErrorView: ResourceLoadErrorView
    private let resourceView: View
    private let mapper: Mapper
    
    var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(loadingView: ResourceLoadingView, resourceView: View, resourceLoadErrorView: ResourceLoadErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceLoadErrorView = resourceLoadErrorView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        resourceLoadErrorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(mapper(resource))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        resourceLoadErrorView.display(.error(message: feedLoadError))
    }
}

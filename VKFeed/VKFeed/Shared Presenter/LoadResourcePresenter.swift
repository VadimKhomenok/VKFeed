//
//  LoadResourcePresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 18.06.22.
//

import Foundation

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    
    private let loadingView: ResourceLoadingView
    private let resourceLoadErrorView: ResourceLoadErrorView
    private let resourceView: View
    private let mapper: Mapper
    
    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the resource from the server")
    }
    
    public init(loadingView: ResourceLoadingView, resourceView: View, resourceLoadErrorView: ResourceLoadErrorView, mapper: @escaping Mapper) {
        self.loadingView = loadingView
        self.resourceLoadErrorView = resourceLoadErrorView
        self.resourceView = resourceView
        self.mapper = mapper
    }
    
    public init(loadingView: ResourceLoadingView, resourceView: View, resourceLoadErrorView: ResourceLoadErrorView) where Resource == View.ResourceViewModel {
        self.loadingView = loadingView
        self.resourceLoadErrorView = resourceLoadErrorView
        self.resourceView = resourceView
        self.mapper = { $0 }
    }
    
    public func didStartLoading() {
        resourceLoadErrorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            try resourceView.display(mapper(resource))
            loadingView.display(ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        resourceLoadErrorView.display(.error(message: Self.loadError))
    }
}

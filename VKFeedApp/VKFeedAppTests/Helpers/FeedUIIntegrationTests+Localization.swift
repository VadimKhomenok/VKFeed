//
//  FeedViewControllerTests+Localization.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 17.05.22.
//

import Foundation
import XCTest
import VKFeed

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        typealias ResourceViewModel = Any
        
        func display(_ viewModel: Any) {}
    }
    
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var loadFeedTitle: String {
        FeedPresenter.title
    }
}

extension CommentsUIIntegrationTests {
    var commentsTitle: String {
        ImageCommentsPresenter.title
    }
}

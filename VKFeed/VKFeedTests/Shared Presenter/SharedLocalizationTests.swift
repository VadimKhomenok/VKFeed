//
//  SharedLocalizationTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 19.06.22.
//

import XCTest
@testable import VKFeed

final class SharedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        assertLocalizedKeysExist(in: bundle, table)
    }
    
    // MARK: - Helpers
    
    private class DummyView: ResourceView {
        typealias ResourceViewModel = Any
        
        func display(_ viewModel: Any) {}
    }
}

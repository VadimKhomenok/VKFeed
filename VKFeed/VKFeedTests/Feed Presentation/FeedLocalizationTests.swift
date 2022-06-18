//
//  FeedLocalizationTests.swift
//  VKFeediOSTests
//
//  Created by Vadim Khomenok on 17.05.22.
//

import XCTest
@testable import VKFeed

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeysExist(in: bundle, table)
    }
}

//
//  ImageCommentsLocalizationsTests.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.06.22.
//

import XCTest
@testable import VKFeed

final class ImageCommentsLocalizationsTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeysExist(in: bundle, table)
    }
}

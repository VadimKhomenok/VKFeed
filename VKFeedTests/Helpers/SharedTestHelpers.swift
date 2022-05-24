//
//  SharedTestHelpers.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 21.04.22.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "https://api-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "An error", code: 400)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

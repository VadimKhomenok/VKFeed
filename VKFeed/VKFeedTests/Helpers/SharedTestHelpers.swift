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
 
func makeItemsJson(_ items: [[String : Any]]) -> Data {
    let itemsJson = [
        "items" : items
    ]
    return try! JSONSerialization.data(withJSONObject: itemsJson)
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
}

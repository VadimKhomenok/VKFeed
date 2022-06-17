//
//  HTTPURLResponse+ConvenienceInit.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 17.06.22.
//

import Foundation

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

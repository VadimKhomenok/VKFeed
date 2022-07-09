//
//  FeedImageDataLoader.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 10.05.22.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}

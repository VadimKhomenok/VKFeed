//
//  FeedImageViewModel.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 25.05.22.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public var description: String?
    public var location: String?
    public var isLoading: Bool
    public var isRetry: Bool
    public var image: Image?
}

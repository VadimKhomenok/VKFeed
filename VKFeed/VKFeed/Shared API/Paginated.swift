//
//  Paginated.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 6.07.22.
//

import Foundation

public struct Paginated<Item> {
    public typealias LoadMoreCompletion = Result<Self, Swift.Error>
    
    public let items: [Item]
    public let loadMore: ((LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((LoadMoreCompletion) -> Void)? = nil) {
         self.items = items
         self.loadMore = loadMore
     }
}

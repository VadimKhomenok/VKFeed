//
//  FeedErrorViewModel.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 24.05.22.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}

//
//  ResourceLoadErrorViewModel.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.06.22.
//

import Foundation

public struct ResourceLoadErrorViewModel {
    public let message: String?
    
    public static var noError: ResourceLoadErrorViewModel {
        return ResourceLoadErrorViewModel(message: .none)
    }
    
    public static func error(message: String) -> ResourceLoadErrorViewModel {
        ResourceLoadErrorViewModel(message: message)
    }
}

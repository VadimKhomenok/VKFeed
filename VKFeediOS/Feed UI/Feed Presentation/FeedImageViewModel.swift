//
//  FeedImageViewModel.swift
//  VKFeediOS
//
//  Created by Vadim Khomenok on 14.05.22.
//

struct FeedImageViewData<Image> {
    var description: String?
    var location: String?
    var isLoading: Bool
    var isRetry: Bool
    var image: Image?
    
    var hasLocation: Bool {
        return location != nil
    }
    
    var hasDescription: Bool {
        return description != nil
    }
}

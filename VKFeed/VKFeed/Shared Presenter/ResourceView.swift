//
//  ResourceView.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.06.22.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

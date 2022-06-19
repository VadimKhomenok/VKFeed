//
//  ResourceLoadErrorView.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 19.06.22.
//

import Foundation

public protocol ResourceLoadErrorView {
    func display(_ viewModel: ResourceLoadErrorViewModel)
}

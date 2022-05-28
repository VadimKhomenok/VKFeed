//
//  HTTPURLResponse+StatusCode.swift
//  VKFeedTests
//
//  Created by Vadim Khomenok on 28.05.22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}

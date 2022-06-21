//
//  ImageCommentsPresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 21.06.22.
//

import Foundation

public struct ImageCommentsViewModel {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public var message: String
    public var date: String
    public var username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: ImageCommentsPresenter.self),
                                 comment: "Title for the image comments view")
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let dateFormatter = RelativeDateTimeFormatter()
        
        return ImageCommentsViewModel(comments: comments
            .map { comment in
                ImageCommentViewModel(
                    message: comment.message,
                    date: dateFormatter.localizedString(for: comment.createdAt, relativeTo: Date()),
                    username: comment.username)
            })
    }
}

//
//  ImageCommentsPresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 21.06.22.
//

import Foundation

public struct ImageCommentsViewModel: Hashable {
    public let comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Hashable {
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
    
    public static func map(
        comments: [ImageComment],
        currentDate: Date = Date(),
        calendar: Calendar = Calendar.current,
        locale: Locale = Locale.current
    ) -> ImageCommentsViewModel {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.calendar = calendar
        dateFormatter.locale = locale
        
        return ImageCommentsViewModel(comments: comments
            .map { comment in
                ImageCommentViewModel(
                    message: comment.message,
                    date: dateFormatter.localizedString(for: comment.createdAt, relativeTo: currentDate),
                    username: comment.username)
            })
    }
}

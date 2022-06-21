//
//  ImageCommentsPresenter.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 21.06.22.
//

import Foundation

public class ImageCommentsPresenter {
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
                                 tableName: "ImageComments",
                                 bundle: Bundle(for: ImageCommentsPresenter.self),
                                 comment: "Title for the image comments view")
    }
}

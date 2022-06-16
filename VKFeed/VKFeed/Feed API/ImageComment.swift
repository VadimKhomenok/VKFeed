//
//  ImageComment.swift
//  VKFeed
//
//  Created by Vadim Khomenok on 16.06.22.
//

import Foundation

public struct ImageComment: Equatable {
    public var id: UUID
    public var message: String
    public var createdAt: Date
    public var username: String
    
    public init(id: UUID, message: String, createdAt: Date, username: String) {
          self.id = id
          self.message = message
          self.createdAt = createdAt
          self.username = username
      }
}

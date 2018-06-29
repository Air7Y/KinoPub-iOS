//
//  Comments.swift
//
//  Created by Евгений Дац on 28.06.2018
//  Copyright (c) Evgeny Dats. All rights reserved.
//

import Foundation
import ObjectMapper

public class Comments: Mappable {

  private struct SerializationKeys {
    static let user = "user"
    static let depth = "depth"
    static let unread = "unread"
    static let deleted = "deleted"
    static let id = "id"
    static let created = "created"
    static let message = "message"
    static let rating = "rating"
  }

  public var user: Profile?
  public var depth: Int?
  public var unread: Bool? = false
  public var deleted: Bool? = false
  public var id: Int?
  public var created: Int?
  public var message: String?
  public var rating: String?

  public required init?(map: Map){

  }

  public func mapping(map: Map) {
    user <- map[SerializationKeys.user]
    depth <- map[SerializationKeys.depth]
    unread <- map[SerializationKeys.unread]
    deleted <- map[SerializationKeys.deleted]
    id <- map[SerializationKeys.id]
    created <- map[SerializationKeys.created]
    message <- map[SerializationKeys.message]
    rating <- map[SerializationKeys.rating]
  }

}

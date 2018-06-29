//
//  CommentsResponse.swift
//
//  Created by Евгений Дац on 28.06.2018
//  Copyright (c) Evgeny Dats. All rights reserved.
//

import Foundation
import ObjectMapper

public class CommentsResponse: Mappable {

  private struct SerializationKeys {
    static let status = "status"
    static let item = "item"
    static let comments = "comments"
  }

  public var status: Int?
  public var item: Item? // Only `id` and `title`
  public var comments: [Comments]?

  public required init?(map: Map){

  }

  public func mapping(map: Map) {
    status <- map[SerializationKeys.status]
    item <- map[SerializationKeys.item]
    comments <- map[SerializationKeys.comments]
  }
}

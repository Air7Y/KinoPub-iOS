//
//  Profile.swift
//
//  Created by hintoz on 26.05.17
//  Copyright (c) . All rights reserved.
//


import Foundation
import ObjectMapper

public class Profile: Mappable {
    
    private struct SerializationKeys {
        static let id = "id"
        static let avatar = "avatar"
        static let name = "name"
    }
    
    public var id: Int?
    public var avatar: String!
    public var name: String!
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map[SerializationKeys.id]
        avatar <- map[SerializationKeys.avatar]
        name <- map[SerializationKeys.name]
    }
}

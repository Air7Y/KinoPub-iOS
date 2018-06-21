import Foundation
import ObjectMapper

public class BookmarkResponse: Mappable {
    
    private struct SerializationKeys {
        static let status = "status"
        static let folder = "folder"
    }
    
    public var status: Int!
    public var folder: Bookmarks?
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        status <- map[SerializationKeys.status]
        folder <- map[SerializationKeys.folder]
    }
}

public class Bookmarks: Mappable {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let updated = "updated"
    static let title = "title"
    static let views = "views"
    static let id = "id"
    static let created = "created"
    static let count = "count"
  }

  // MARK: Properties
  public var updated: Int!
  public var title: String!
  public var views: Int!
  public var id: Int!
  public var created: Int!
  public var count: String!

  
  public required init?(map: Map){

  }

  public func mapping(map: Map) {
    updated <- map[SerializationKeys.updated]
    title <- map[SerializationKeys.title]
    views <- map[SerializationKeys.views]
    id <- map[SerializationKeys.id]
    created <- map[SerializationKeys.created]
    count <- map[SerializationKeys.count]
  }
}

extension Bookmarks: Equatable {
    public static func == (lhs: Bookmarks, rhs: Bookmarks) -> Bool {
        return lhs.id == rhs.id
    }
}

public class BookmarksToggle: Mappable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let status = "status"
        static let exists = "exists"
    }
    
    // MARK: Properties
    public var status: Int?
    public var exists: Bool?
    
    public required init?(map: Map){
        
    }
    public func mapping(map: Map) {
        status <- map[SerializationKeys.status]
        exists <- map[SerializationKeys.exists]
    }
}

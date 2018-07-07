import Foundation
import ObjectMapper

public class Seasons: ImmutableMappable {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let episodes = "episodes"
        static let number = "number"
        static let title = "title"
        static let watching = "watching"
    }
    
    // MARK: Properties
    public let number: Int
    public let title: String
    public let watching: Watching
    public var episodes: [Episodes]
    
    public required init(map: Map) throws {
        number = try map.value(SerializationKeys.number)
        title = try map.value(SerializationKeys.title)
        watching = try map.value(SerializationKeys.watching)
        episodes = try map.value(SerializationKeys.episodes)
    }
}

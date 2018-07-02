import Foundation

struct Filter: ReflectedStringConvertible {
    
    var genres: Set<Genres>?
    var countries: Set<Countries>?
    var subtitles: SubtitlesList?
    var year: String?
    var yearsDict: [String : String]?
    var imdbRating: [String : String]?
    var kinopoiskRating: [String : String]?
    var sort: SortOption!
    var sortAsc: Bool
    var serialStatus: SerialStatus!
    
    static var defaultFilter: Filter {
        let filter = Filter(genres: nil,
                            countries: nil,
                            subtitles: nil,
                            year: nil,
                            yearsDict: nil,
                            imdbRating: nil,
                            kinopoiskRating: nil,
                            sort: SortOption.updated,
                            sortAsc: false,
                            serialStatus: .any)
        return filter
    }
    
    var isSet: Bool {
        if genres != nil ||
            countries != nil ||
            subtitles != nil ||
            year != nil ||
            sort !=
            SortOption.updated ||
            sortAsc ||
            serialStatus != .any ||
            imdbRating != nil ||
            kinopoiskRating != nil {
            return true
        }
        return false
    }
    
}

extension Filter: Equatable {
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return lhs.genres == rhs.genres && lhs.yearsDict! == rhs.yearsDict!
    }
}

extension Filter {
    var parameters: [String : String]? {
        var param = [String : String]()
        if let genres = genres {
            param["genre"] = genres.toString
        }
        if let countries = countries {
            param["country"] = countries.toString
        }
        if let subtitles = subtitles {
            param["subtitles"] = subtitles.id
        }
        if let year = year {
            switch year {
            case "Не важно":
                param["year"] = ""
            case "Период", "Начиная с":
                if var yearsDict = yearsDict {
                    guard let year1 = yearsDict["from"], let year2 = yearsDict["to"] else { break }
                    if year1.int! > year2.int! { yearsDict.swap("from", "to") }
                    param["year"] = "\(year1)-\(year2)"
                }
            default:
                param["year"] = year
            }
        }
        if let serialStatus = serialStatus {
            switch serialStatus {
            case .inAir, .finished:
                param["finished"] = serialStatus.rawValue.string
            case .any:
                param["finished"] = nil
            }
        }
        if let imdbRating = imdbRating {
            for (offset: index, element: (key: key, value: value)) in imdbRating.enumerated() {
                param["conditions[\(index)]"] = "imdb_rating \(key) \(value.replacingOccurrences(of: " и выше", with: ""))"
            }
        }
        if let kinopoiskRating = kinopoiskRating {
            for (offset: index, element: (key: key, value: value)) in kinopoiskRating.enumerated() {
                param["conditions[\(index + 2)]"] = "kinopoisk_rating \(key) \(value.replacingOccurrences(of: " и выше", with: ""))"
            }
        }
        param["sort"] = sortAsc ? sort.asc() : sort.desc()
        
        return param.count > 0 ? param : nil
    }
}

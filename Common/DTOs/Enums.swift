import Foundation

enum GenreType: String {
    case movie = "movie"
    case music = "music"
    case documentary = "docu"
    case tvshow = "tvshow"
}

enum ItemType: String, CustomStringConvertible {
    
    case movies = "movie"
    case shows = "serial"
    case tvshows = "tvshow"
    case movies3d = "3d"
    case concerts = "concert"
    case documovie = "documovie"
    case docuserial = "docuserial"
    case movies4k = "4k"
    case cartoons = "cartoons"
    
    var tag: Int {
        switch self {
        case .movies:
            return 0
        case .shows:
            return 1
        case .cartoons:
            return 2
        case .tvshows:
            return 5
        case .movies3d:
            return 10
        case .concerts:
            return 6
        case .documovie:
            return 3
        case .docuserial:
            return 4
        case .movies4k:
            return 9
        }
    }
    
    var description: String {
        switch self {
        case .movies:
            return "Фильмы"
        case .shows:
            return "Сериалы"
        case .tvshows:
            return "ТВ-Шоу"
        case .movies3d:
            return "Фильмы в 3D"
        case .concerts:
            return "Концерты"
        case .documovie:
            return "Документальные фильмы"
        case .docuserial:
            return "Документальные сериалы"
        case .movies4k:
            return "Фильмы в 4K"
        case .cartoons:
            return "Мультфильмы"
        }
    }
    
    init() {
        self = .movies
    }
    func genre() -> GenreType {
        switch self {
        case .tvshows:
            return .tvshow
        case .movies, .shows, .movies3d, .movies4k, .cartoons:
            return .movie
        case .concerts:
            return .music
        case .documovie, .docuserial:
            return .documentary
        }
    }
    enum ItemSubtype: String {
        case multi = "multi"
    }
}

public enum SubLang: String, CustomStringConvertible, Equatable {
    case rus = "rus"
    case eng = "eng"
    case ukr = "ukr"
    case fre = "fre"
    case ger = "ger"
    case spa = "spa"
    case ita = "ita"
    case por = "por"
    case fin = "fin"
    
    public var description: String {
        switch self {
        case .rus:
            return "Русские"
        case .eng:
            return "Английские"
        case .ukr:
            return "Украинские"
        case .fre:
            return "Французкие"
        case .ger:
            return "Немецкие"
        case .spa:
            return "Испанские"
        case .ita:
            return "Итальянские"
        case .por:
            return "Португальские"
        case .fin:
            return "Финские"
        }
    }
}

enum SerialStatus: Int, CustomStringConvertible {
    case inAir
    case finished
    case any
    
    static let all = [any, inAir, finished]
    
    var description: String {
        switch self {
        case .any:
            return "Все"
        case .inAir:
            return "В эфире"
        case .finished:
            return "Завершенные"
        }
    }
}

enum Period: String, CustomStringConvertible {
    case allTime
    case day
    case week
    case month
    case quarter
    
    static let all = [allTime, day, week, month, quarter]
    
    var description: String {
        switch self {
        case .allTime:
            return "За все время"
        case .day:
            return "За сутки"
        case .week:
            return "За неделю"
        case .month:
            return "За месяц"
        case .quarter:
            return "За квартал"
        }
    }
    
    var condition: String {
        switch self {
        case .allTime:
            return ""
        case .day:
            return "created>\(Date().timeIntervalSince1970 - 3600 * 24)"
        case .week:
            return "created>\(Date().timeIntervalSince1970 - 3600 * 24 * 7)"
        case .month:
            return "created>\(Date().timeIntervalSince1970 - 3600 * 24 * 30)"
        case .quarter:
            return "created>\(Date().timeIntervalSince1970 - 3600 * 24 * 91)"
        }
    }
}

enum SortOption: String, CustomStringConvertible {
    
    init?(string stringValue: String) {
        return nil
    }
    
    case id
    case year
    case title
    case created
    case updated
    case rating
    case kinopoisk_rating
    case imdb_rating
    case views
    case watchers
    
    static let all = [updated, created, year, title, rating, kinopoisk_rating, imdb_rating, views, watchers]
    
    func name() -> String {
        switch self {
        case .id:
            return "по Id"
        case .year:
            return "по году выпуска"
        case .title:
            return "по названию"
        case .created:
            return "по дате добавления"
        case .updated:
            return "по дате обновления"
        case .rating:
            return "по рейтингу"
        case .kinopoisk_rating:
            return "по кинопоиску"
        case .imdb_rating:
            return "по imdb"
        case .views:
            return "по просмотрам"
        case .watchers:
            return "по кол-ву смотрящих"
        }
    }
    
    func desc() -> String {
        return "-\(self.rawValue)"
    }
    
    func asc() -> String {
        return self.rawValue
    }
    
    var description: String {
        return self.name()
    }
    
    var suggestionString: String {
        return self.rawValue
    }
}

enum TabBarItemTag: Int, Codable {
    case movies = 0
    case shows = 1
    case cartoons = 2
    case documovie = 3
    case docuserial = 4
    case tvshow = 5
    case concert = 6
    case bookmarks = 7
    case collections = 8
    case movies4k = 9
    case movies3d = 10
    case newMovies = 11
    case newSeries = 12
    case hotMovies = 13
    case hotSeries = 14
    case freshMovies = 15
    case freshSeries = 16
    
    case watchlist = 99

    var description: String {
        switch self {
        case .movies:
            return "Фильмы"
        case .shows:
            return "Сериалы"
        case .tvshow:
            return "ТВ-Шоу"
        case .movies3d:
            return "Фильмы в 3D"
        case .concert:
            return "Концерты"
        case .documovie:
            return "Документальные фильмы"
        case .docuserial:
            return "Документальные сериалы"
        case .movies4k:
            return "Фильмы в 4K"
        case .cartoons:
            return "Мультфильмы"
        case .collections:
            return "Подборки"
        case .newMovies:
            return "Новые фильмы"
        case .newSeries:
            return "Новые сериалы"
        case .hotMovies:
            return "Популярные фильмы"
        case .hotSeries:
            return "Популярные сериалы"
        case .freshMovies:
            return "Свежие фильмы"
        case .freshSeries:
            return "Свежие сериалы"
        default:
            return "default"
        }
    }
    
    var stringValue: String {
        switch self {
        case .movies:
            return "movie"
        case .shows:
            return "serial"
        case .cartoons:
            return "cartoons"
        case .documovie:
            return "documovie"
        case .docuserial:
            return "docuserial"
        case .tvshow:
            return "tvshow"
        case .concert:
            return "concert"
        case .movies4k:
            return "4k"
        case .movies3d:
            return "3d"
        default:
            return "nil"
        }
    }
}

public enum Status: Int {
    case unwatched = -1
    case watching = 0
    case watched = 1
}

public enum Serial: Int {
    case watching = 1
    case used = 0
}

enum InWatchlist: String {
    case watching = "Смотрю"
    case willWatch = "Буду смотреть"

}

import Foundation

struct MenuItems: Codable {
    let id: String
    let name: String
    let icon: String
    let tag: TabBarItemTag?
    
    // Content Menu
    static var mainVC: MenuItems {
        return MenuItems(id: "HomeNavVc", name: "Главная", icon: "Main", tag: nil)
    }
    static var filmsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Фильмы", icon: "Movies", tag: .movies)
    }
    static var seriesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Сериалы", icon: "Series", tag: .shows)
    }
    static var cartoonsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Мультфильмы", icon: "Cartoons", tag: .cartoons)
    }
    static var docMoviesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Документальные фильмы", icon: "Documentary Movie", tag: .documovie)
    }
    static var docSeriesVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Документальные сериалы", icon: "Documentary Series", tag: .docuserial)
    }
    static var tvShowsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "ТВ шоу", icon: "Television", tag: .tvshow)
    }
    static var concertsVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Концерты", icon: "Concert", tag: .concert)
    }
    static var collectionsVC: MenuItems {
        return MenuItems(id: "CollectionsNavVC", name: "Подборки", icon: "Collection", tag: .collections)
    }
    static var movies4kVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Фильмы в 4K", icon: "4K", tag: .movies4k)
    }
    static var movies3dVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Фильмы в 3D", icon: "3D", tag: .movies3d)
    }
    static var tvSportVC: MenuItems {
        return MenuItems(id: "SportNavVC", name: "Спортивные каналы", icon: "Sports", tag: nil)
    }
    
    // User Menu
    static var watchlistVC: MenuItems {
        return MenuItems(id: "ItemNavVC", name: "Я смотрю", icon: "Eye", tag: .watchlist)
    }
    static var bookmarksVC: MenuItems {
        return MenuItems(id: "BokmarksNavVC", name: "Закладки", icon: "Folder", tag: nil)
    }
    static var downloadsVC: MenuItems {
        return MenuItems(id: "DownloadNavVC", name: "Загрузки", icon: "Download", tag: nil)
    }
    
    // Settings Menu
    static var settingsVC: MenuItems {
        return MenuItems(id: "SettingsNavVC", name: "Настройки", icon: "Settings", tag: nil)
    }
    
    #if os(iOS)
    static let hiddenMenuItemsDefault = [movies4kVC, movies3dVC]
    static let configurableMenuItems = [filmsVC, seriesVC, cartoonsVC, docMoviesVC, docSeriesVC, tvShowsVC, concertsVC, collectionsVC, movies4kVC, movies3dVC, tvSportVC]
    static let jsonFileForHiddenMenuItems = "configMenu.json"
    
    static let userMenu = [watchlistVC, bookmarksVC, downloadsVC]
    static let contentMenu = [mainVC] + Config.shared.hiddenMenusService.loadConfigMenu()
    static let settingsMenu = [settingsVC]
    static let all = userMenu + contentMenu + settingsMenu
    #endif
    
    static let atvMenu = [filmsVC, seriesVC, cartoonsVC, movies4kVC, movies3dVC, docMoviesVC, docSeriesVC, tvShowsVC, concertsVC]
    
}

extension MenuItems: Hashable {
    public var hashValue: Int {
        return name.hashValue
    }
    
    static func ==(lhs: MenuItems, rhs: MenuItems) -> Bool {
        return lhs.name == rhs.name
    }
}

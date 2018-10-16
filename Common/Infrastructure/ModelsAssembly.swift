import SwiftyBeaver

struct Container {
    struct Manager {
        static let account: AccountManager = AccountManagerImp()
        static let media = MediaManager()
        static let logViews: LogViewsManager = LogViewsManagerImp()
        static let analytics = AnalyticsManager()
    }
    
    struct Service {
        static let log = { () -> SwiftyBeaver.Type in
            let log = SwiftyBeaver.self
            let platform = SBPlatformDestination(appID: "Gw3Gap", appSecret: "sfyvuwb5Xrlfeitss3utgireKicRamnQ", encryptionKey: "7goj45Muq6nzsvnpctcjfVswNu6Vlp6h")
            log.addDestination(ConsoleDestination())
            log.addDestination(platform)
            return log
        }()
    }
    
    struct ViewModel {
        static let auth = { AuthModel(accountManager: Manager.account) }
        static let videoItems = { VideoItemsModel(accountManager: Manager.account) }
        static let profile = { ProfileModel(accountManager: Manager.account) }
        static let videoItem = { VideoItemModel(accountManager: Manager.account) }
        #if os(iOS)
        static let bookmarks = { BookmarksModel(accountManager: Manager.account) }
        static let collection = { CollectionModel(accountManager: Manager.account) }
        static let filter = { FilterModel(accountManager: Manager.account) }
        static let tv = { TVModel(accountManager: Manager.account) }
        static let comments = { CommentsModel(accountManager: Manager.account) }
        #endif
    }
}

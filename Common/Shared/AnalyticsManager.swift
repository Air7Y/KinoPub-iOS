import Foundation
import Mixpanel
import Fabric
import Crashlytics
#if os(iOS)
import Firebase
#endif

class AnalyticsManager {
    private let mixpanelManager: Mixpanel
    
    private let gcmMessageIDKey = Config.firebase.gcmMessageIDKey
    init() {
        mixpanelManager = Mixpanel.sharedInstance(withToken: Config.Mixpanel.token)
    }
    
    func setup() {
        Fabric.with([Crashlytics.self])
        #if os(iOS)
        FirebaseApp.configure()
        #endif
    }
    
    func flush() {
        mixpanelManager.flush()
    }
    
    var debug = false {
        didSet {
            Fabric.sharedSDK().debug = debug
        }
    }
}

// Remote Notifications
extension AnalyticsManager {
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        print(userInfo)
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        didReceiveRemoteNotification(userInfo: userInfo)
        completionHandler(.noData)
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
    }
}

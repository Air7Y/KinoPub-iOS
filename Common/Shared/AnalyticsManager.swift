import Foundation
import Mixpanel
import Fabric
import Crashlytics
import CocoaLumberjack
#if os(iOS)
import Firebase
#endif

class AnalyticsManager {
    private let mixpanelManager: Mixpanel
    
    private let gcmMessageIDKey = Config.firebase.gcmMessageIDKey
    
    private var fileLogger: DDFileLogger
    
    init() {
        mixpanelManager = Mixpanel.sharedInstance(withToken: Config.Mixpanel.token)
        fileLogger = DDFileLogger() // File Logger
    }
    
    func setup() {
        Fabric.with([Crashlytics.self])
        #if os(iOS)
        FirebaseApp.configure()
        #endif
        
        DDLog.add(DDTTYLogger.sharedInstance)
        DDLog.add(DDASLLogger.sharedInstance)
        
        fileLogger.rollingFrequency = TimeInterval(60*60)  // 1 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)
        
        DDLogVerbose("LOGGING STARTED")
        DDASLLogCapture.start()
    }
    
    func flush() {
        mixpanelManager.flush()
    }
    
    var debug = false {
        didSet {
            Fabric.sharedSDK().debug = debug
        }
    }
    
    func writeTTYToFile() {
        let logFilePath = fileLogger.logFileManager.logsDirectory.appendingPathComponent("/Console0.log")
        
        if (isatty(STDIN_FILENO) == 0) {
            freopen(logFilePath, "a+", stderr)
            freopen(logFilePath, "a+", stdin)
            freopen(logFilePath, "a+", stdout)
            print("stderr, stdin, stdout redirected to \"\(logFilePath)\"")
        } else {
            print("stderr, stdin, stdout NOT redirected, STDIN_FILENO = \(STDIN_FILENO)")
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

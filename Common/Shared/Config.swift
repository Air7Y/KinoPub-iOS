import UIKit
import SwiftyUserDefaults
#if os(iOS)
import FirebaseRemoteConfig
#endif

protocol ConfigDelegate: class {
    func configDidLoad()
}

class Config {
    static let shared = Config()
    weak var delegate: ConfigDelegate?
    
    #if os(iOS)
    var remoteConfig: RemoteConfig!
    let hiddenMenusService: HiddenMenusService
    let defaultValues = [
        "kinopubClientId" : Defaults[.kinopubClientId] as NSObject,
        "kinopubClientSecret" : Defaults[.kinopubClientSecret] as NSObject,
        "delayViewMarkTime" : Defaults[.delayViewMarkTime] as NSObject,
        "kinopubDomain" : Defaults[.kinopubDomain] as NSObject
                         ]
    #endif

    var appVersion: String {
        if let dictionary = Bundle.main.infoDictionary {
            let version = dictionary["CFBundleShortVersionString"] as! String
            let build = dictionary["CFBundleVersion"] as! String
            return "Версия \(version), билд \(build)"
        }
        return ""
    }
    
    var kinopubClientId: String {
        #if os(iOS)
        return remoteConfig["kinopubClientId"].stringValue ?? kinopub.clientId
        #elseif os(tvOS)
        return kinopub.clientId
        #endif
    }
    
    var kinopubClientSecret: String {
        #if os(iOS)
        return remoteConfig["kinopubClientSecret"].stringValue ?? kinopub.clientSecret
        #elseif os(tvOS)
        return kinopub.clientSecret
        #endif
    }
    
    var delayViewMarkTime: TimeInterval {
        #if os(iOS)
        return remoteConfig["delayViewMarkTime"].numberValue as? TimeInterval ?? 180
        #elseif os(tvOS)
        return 180
        #endif
    }
    
    var kinopubDomain: String {
        #if os(iOS)
        return remoteConfig["kinopubDomain"].stringValue ?? kinopub.domain
        #elseif os(tvOS)
        return kinopub.domain
        #endif
    }
    
    var clientTitle: String {
        return Defaults[.clientTitle]
    }
    
    var clientHardware: String {
        return UIDevice().model
    }
    
    var clientSoftware: String {
        return UIDevice().type.rawValue + " (" + UIDevice().systemName + " " + UIDevice().systemVersion + ") KinoPub/dats.xyz"
    }
    
    var menuItem: Int {
        return Defaults[.menuItem]
    }
    
    var streamType: String {
        return Defaults[.streamType]
    }
    
    var logViews: Bool {
        return Defaults[.logViews]
    }
    
    var canSortSeasons: Bool {
        return Defaults[.canSortSeasons]
    }
    
    var canSortEpisodes: Bool {
        return Defaults[.canSortEpisodes]
    }
    
    var animeIsHidden: Bool {
        return Defaults[.animeIsHidden]
    }
    
    var menuVisibleContentWidth: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 1.6 : 5
    }
    
    init() {
        #if os(iOS)
        hiddenMenusService = HiddenMenusService()
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.setDefaults(defaultValues)
        fetchRemoteConfig()
        #endif
    }
    
    #if os(iOS)
    func fetchRemoteConfig() {
        #if DEBUG
            // FIXME: Remove before production!
            let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.configSettings = remoteConfigSettings
        #endif
        
        remoteConfig.fetch(withExpirationDuration: 0) { [unowned self] (status, error) in
            guard error == nil else {
                print("Error fetch remote config: \(error?.localizedDescription ?? "unknown")")
                return
            }
            self.writeInUserDefaults()
            self.remoteConfig.activateFetched()
            self.delegate?.configDidLoad()
        }
    }
    
    func writeInUserDefaults() {
        Defaults[.kinopubClientId] = remoteConfig["kinopubClientId"].stringValue!
        Defaults[.kinopubClientSecret] = remoteConfig["kinopubClientSecret"].stringValue!
        Defaults[.delayViewMarkTime] = remoteConfig["delayViewMarkTime"].numberValue as! TimeInterval
        Defaults[.kinopubDomain] = remoteConfig["kinopubDomain"].stringValue!
    }
    #endif
}

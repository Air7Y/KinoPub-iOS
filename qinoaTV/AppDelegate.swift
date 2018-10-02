//
//  AppDelegate.swift
//  qinoaTV
//
//  Created by Евгений Дац on 18.05.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import SwifterSwift
import AlamofireNetworkActivityLogger
import SwiftyUserDefaults

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    fileprivate let analyticsManager = Container.Manager.analytics

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        
        analyticsManager.setup()
        analyticsManager.debug = true
        
        registerSettingsBundle()
        setDefaults()
        
        awakeObjects()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func awakeObjects() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyObject.Type>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount))
        for index in 0 ..< typeCount { (types[index] as? Object.Type)?.awake() }
        types.deallocate()
    }
    
    func configAppearance() {
        UINavigationBar.appearance().tintColor = .kpOffWhite
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.kpOffWhite]
        UITextField.appearance().keyboardAppearance = .dark
        UITableViewCell.appearance().backgroundColor = .clear
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.kpOffWhite], for: .normal)
    }

    func registerSettingsBundle() {
        let appDefaults = [String: AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    func setDefaults() {
        if UserDefaults.standard.object(forKey: "showRatringInPoster") == nil {
            Defaults[.showRatringInPoster] = true
        }
        
        if UserDefaults.standard.object(forKey: "logViews") == nil {
            Defaults[.logViews] = true
        }
        
        if UserDefaults.standard.object(forKey: "streamType") == nil {
            Defaults[.streamType] = "hls4"
        }
        
        if UserDefaults.standard.object(forKey: "clientTitle") == nil {
            Defaults[.clientTitle] = UIDevice().name
        }
    }

}


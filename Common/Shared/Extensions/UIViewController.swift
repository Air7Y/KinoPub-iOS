//
//  UIViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 07.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

extension UIViewController {
    public static var topVC: UIViewController? {
        var result: UIViewController? = nil
        guard var window = UIApplication.shared.keyWindow else {
            return nil
        }
        if window.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindowLevelNormal {
                    window = tmpWin
                    break
                }
            }
        }
        result = window.rootViewController
        while let presentedVC = result?.presentedViewController {
            result = presentedVC
        }
        if result is UITabBarController {
            result = (result as? UITabBarController)?.selectedViewController
        }
        while result is UINavigationController && (result as? UINavigationController)?.topViewController != nil{
            result = (result as? UINavigationController)?.topViewController
        }
        return result
    }
}

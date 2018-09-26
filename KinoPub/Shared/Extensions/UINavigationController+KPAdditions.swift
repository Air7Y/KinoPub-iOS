//
//  UINavigationController+KPAdditions.swift
//  KinoPub
//
//  Created by Евгений Дац on 26.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}

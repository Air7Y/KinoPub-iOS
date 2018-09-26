//
//  NavigationController.swift
//  KinoPub
//
//  Created by hintoz on 14.04.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class NavigationController: UINavigationController, SideMenuItemContent {
    
    var defaultBackImage: UIImage!
    var defaultShadowImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .black
        
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.kpOffWhite]
            navigationBar.largeTitleTextAttributes = attributes
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        if self.topViewController != nil {
            return self.topViewController!.shouldAutorotate
        } else {
            return  super.shouldAutorotate
        }
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if self.topViewController != nil{
            return self.topViewController!.supportedInterfaceOrientations
        }else{
            return  super.supportedInterfaceOrientations
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if self.topViewController != nil{
            return self.topViewController!.preferredInterfaceOrientationForPresentation
        }else{
            return  super.preferredInterfaceOrientationForPresentation
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.topViewController!.preferredStatusBarStyle
    }

}

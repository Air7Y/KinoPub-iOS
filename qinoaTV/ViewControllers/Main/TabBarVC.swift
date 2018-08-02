//
//  TabBarVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 09.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    fileprivate let accountManager = Container.Manager.account

    override func viewDidLoad() {
        super.viewDidLoad()

        accountManager.addDelegate(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chechAccount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    var environmentsToFocus: [UIFocusEnvironment] = []
//    
//    override var preferredFocusEnvironments: [UIFocusEnvironment] {
//        defer { environmentsToFocus.removeAll() }
//        return environmentsToFocus.isEmpty ? super.preferredFocusEnvironments : environmentsToFocus
//    }
//    
//    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//        guard
//            let previouslyFocusedView = context.previouslyFocusedView,
//            let nextFocusedView = context.nextFocusedView,
//            let navigationController = selectedViewController as? UINavigationController,
//            let root = navigationController.topViewController as? MainVC,
//            let collectionView = root.collectionView,
//            let items = root.navigationItem.rightBarButtonItems,
//            !items.isEmpty,
//            collectionView.contentOffset.y + collectionView.contentInset.top < 100 // Make sure we're more or less at the top
//            else {
//                return true
//        }
//        
//        let previousType = type(of: previouslyFocusedView)
//        let nextType = type(of: nextFocusedView)
//        
//        if (previousType === NSClassFromString("UITabBarButton") && nextType is UICollectionViewCell.Type) || (nextType === NSClassFromString("UITabBarButton") && previousType is UICollectionViewCell.Type) // If the tabBarController is about to loose focus to a collectionViewCell or about to gain focus from a collectionViewCell, focus on the tabBarButtons first.
//        {
//            environmentsToFocus = items.compactMap({$0.customView}).reversed()
//            setNeedsFocusUpdate()
//            
//            return false
//        }
//        
//        return true
//    }
    

    func chechAccount() {
        if !accountManager.hasAccount {
            showAuthViewController()
        }
    }
    
    func showAuthViewController() {
        if let authViewController = AuthViewController.storyboardInstance() {
            present(authViewController, animated: true, completion: nil)
        } else {
            Helper.showError("Что-то пошло не так.")
        }
    }

}

extension TabBarVC: AccountManagerDelegate {
    func accountManagerDidLogout(accountManager: AccountManager) {
        showAuthViewController()
    }
}

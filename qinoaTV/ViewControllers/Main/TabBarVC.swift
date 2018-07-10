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

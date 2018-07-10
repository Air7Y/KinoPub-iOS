//
//  FirstViewController.swift
//  qinoaTV
//
//  Created by Евгений Дац on 18.05.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    fileprivate let accountManager = Container.Manager.account
    var playButtonGesture: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        accountManager.addDelegate(delegate: self)
        playButtonGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped(_:)))
        playButtonGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
        playButtonGesture.delegate = self
        view.addGestureRecognizer(playButtonGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?[1].title = "First"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?[1].title = ""
    }
    
    @objc func playButtonTapped(_ sender: Any) {
        Helper.showError("Была нажата кнопка Play/Pause")
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        Helper.showErrorTrailerAlert()
    }

}

extension FirstViewController: AccountManagerDelegate {
    
}

extension FirstViewController: UIGestureRecognizerDelegate {
    
}

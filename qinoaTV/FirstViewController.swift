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
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    var environmentsToFocus: [UIFocusEnvironment] = []
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return environmentsToFocus.isEmpty ? super.preferredFocusEnvironments : environmentsToFocus
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        accountManager.addDelegate(delegate: self)
        playButtonGesture = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped(_:)))
        playButtonGesture.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)]
        playButtonGesture.delegate = self
        view.addGestureRecognizer(playButtonGesture)
        
        environmentsToFocus = [segment]
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

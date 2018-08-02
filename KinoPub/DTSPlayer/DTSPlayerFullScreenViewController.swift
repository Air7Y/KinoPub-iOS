//
//  DTSPlayerFullScreenViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 15.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import AVKit
import SwifterSwift
import PMKVObserver

class DTSPlayerFullScreenViewController: AVPlayerViewController {
    
    private var nextItemView: NextItemView?
    private var titleView: TitleView?
    private var playBackControlsView: UIView? {
        let firstSubview = view.subviews.first
        
        if #available(iOS 12.0, *) {
            return firstSubview?.subviews[safe: 1]?.subviews[safe: 1]
        } else if #available(iOS 11.0, *) {
            return firstSubview?.subviews[safe: 2]?.subviews.first
        } else {
            return firstSubview?.subviews[safe: 5]?.subviews.first
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.allowsPictureInPicturePlayback = true
        self.delegate = self
        
        addKVOForItemStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKVOForControlsIsHidden()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .DTSPlayerViewControllerDismissed, object: self, userInfo: nil)
    }
    
    func configNextItemView(with info: String, image: UIImage? = nil) {
        guard nextItemView == nil else {
            nextItemView?.config(with: info, image: image)
            return
        }
        nextItemView = NextItemView.fromNib()
        guard let nextItemView = nextItemView else { return }
        nextItemView.config(with: info, image: image)
        nextItemView.delegate = self
        view.addSubview(nextItemView)
        nextItemView.nextButton.layer.zPosition = 10
        
        nextItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            nextItemView.heightAnchor.constraint(equalToConstant: 47),
            nextItemView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    func configTitle(with info: String) {
        guard titleView == nil else {
            titleView?.config(with: info)
            return
        }
        titleView = TitleView.fromNib()
        guard let titleView = titleView else { return }
        titleView.config(with: info)
        contentOverlayView?.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleView.heightAnchor.constraint(equalToConstant: 47),
            titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    func removeNextButton() {
        nextItemView?.removeFromSuperview()
    }
    
    private func playNextItem() {
        (player as! AVQueuePlayer).advanceToNextItem()
        NotificationCenter.default.post(name: .DTSPlayerUserTappedNextButton, object: self, userInfo: nil)
    }
    
    private func checkHDR() {
        
    }
    
    private func addKVOForControlsIsHidden() {
        guard let view = playBackControlsView else { return }
        _ = KVObserver(observer: self, object: view, keyPath: #keyPath(UIView.isHidden), options: [.new], block: { (observer, object, change, _) in
            guard let newValue = change.new as? Bool else {
                observer.nextItemView?.isHidden = object.isHidden
                return
            }
            observer.nextItemView?.isHidden = newValue
        })
    }
    
    private func addKVOForItemStatus() {
        guard let currentItem = player?.currentItem else { return }
        _ = KVObserver(observer: self, object: currentItem, keyPath: #keyPath(AVPlayerItem.status), options: [.new], block: { (observer, object, change, kvo) in
            let status: AVPlayerItemStatus
            if let statusNumber = change.new as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("STATUS: readyToPlay")
            case .failed:
                // Player item failed. See error.
                print("STATUS: failed")
                print(object.error ?? "Unknown")
                self.dismiss(message: object.error?.localizedDescription)
            case .unknown:
                // Player item is not yet ready.
                print("STATUS: unknown")
                print(object.error ?? "Unknown error")
                self.dismiss(message: object.error?.localizedDescription)
            }
        })
    }
    
    private func dismiss(message: String?) {
        dismiss(animated: true) {
            Helper.showError(message)
        }
    }

}

extension DTSPlayerFullScreenViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        guard let activityViewController = DTSPlayerUtils.activityViewController() else { return }
        activityViewController.present(playerViewController, animated: true) {
            completionHandler(true)
        }
    }
}

extension DTSPlayerFullScreenViewController: NextItemDelegate {
    func didPressNextButton() {
        playNextItem()
    }
}

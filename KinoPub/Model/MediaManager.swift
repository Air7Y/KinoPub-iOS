//
//  MediaManager.swift
//  KinoPub
//
//  Created by hintoz on 26.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import EZPlayer
import LKAlertController
import SwiftyUserDefaults
import AVFoundation
import MediaPlayer
import SubtleVolume
import NDYoutubePlayer
import AVKit

class MediaManager {
    fileprivate let logViewsManager = Container.Manager.logViews
    private var timeObserver: Any?
    var fullScreenViewController: DTSPlayerFullScreenViewController?
    var playerCustom: EZPlayer?
    var playerNative: AVQueuePlayer?
    var mediaItems = [MediaItem]()
    var playerItems = [AVPlayerItem]()
    
    var fixReadyToPlay: Bool = false
    var time: TimeInterval = 0
    var volume: SubtleVolume?
    var isLive = false

    static let shared = MediaManager()
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplayFromDefaults), name: UserDefaults.didChangeNotification, object: nil)

            // Custom
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.EZPlayerPlaybackDidFinish, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerTimeDidChange(_:)), name: NSNotification.Name.EZPlayerPlaybackTimeDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerStatusDidChange(_:)), name: NSNotification.Name.EZPlayerStatusDidChange, object: playerCustom)

            // Native
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerNative?.currentItem)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidClosed(_:)), name: NSNotification.Name.DTSPlayerViewControllerDismissed, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerTimeDidChange(_:)), name: NSNotification.Name.DTSPlayerPlaybackTimeDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(userTappedNextButton(_:)), name: NSNotification.Name.DTSPlayerUserTappedNextButton, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addPlayerItemTimeObserver(){
        timeObserver = playerNative?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(Config.shared.delayViewMarkTime, CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { time in
            NotificationCenter.default.post(name: .DTSPlayerPlaybackTimeDidChange, object: self, userInfo: nil)
        })
    }
    
    func playYouTubeVideo(withID id: String) {
        releaseNativePlayer()
        releasePlayer()
        NDYoutubeClient.shared.getVideoWithIdentifier(videoIdentifier: id) { [weak self] (video, error) in
            guard let video = video else {
                Helper.showErrorTrailerAlert()
                return
            }
            guard let streamURLs = video.streamURLs else { return }
            if let videoString = streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualityHD720.rawValue] ?? streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualityMedium360.rawValue] ?? streamURLs[NDYouTubeVideoQuality.NDYouTubeVideoQualitySmall240.rawValue] {
                let mediaItems = [MediaItem(url: URL(string: videoString as! String)!, title: nil, video: nil, id: nil, season: nil, watchingTime: nil)]
                self?.playVideo(mediaItems: mediaItems)
            }
        }
    }
    
    func playVideo(mediaItems: [MediaItem], userinfo: [AnyHashable : Any]? = nil, isLive: Bool = false) {
        guard playerCustom == nil else {
            playerCustom?.replaceToPlayWithURL((mediaItems.first?.url)!, title: mediaItems.first?.title)
            playerCustom?.toFull()
            return
        }
        releaseNativePlayer()
        releasePlayer()
        self.isLive = isLive
        self.mediaItems = mediaItems
        
        for item in mediaItems {
            var option = [String : Any]()
            if #available(iOS 10.0, *) { option = [AVURLAssetAllowsCellularAccessKey: true] }
            let assetKeys = ["playable"]
            let asset = AVURLAsset(url: item.url!, options: option)
            playerItems.append(AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys))
//            playerItems.append(AVPlayerItem(url: item.url!))
        }
        
        Defaults[.isCustomPlayer] ? playWithCustomPlayer(mediaItems: mediaItems, userinfo: userinfo) : playWithNativePlayer(mediaItems: playerItems, userinfo: userinfo)
    }
    
    // Native Player
    func playWithNativePlayer(mediaItems: [AVPlayerItem], userinfo: [AnyHashable : Any]? = nil) {
        guard let activityViewController = DTSPlayerUtils.activityViewController() else { return }
        playerNative = AVQueuePlayer(items: mediaItems)
        playerNative?.actionAtItemEnd = .advance
        
        playerNative?.allowsExternalPlayback = true
        playerNative?.usesExternalPlaybackWhileExternalScreenIsActive = true
        time = Date().timeIntervalSinceReferenceDate
        !isLive ? addPlayerItemTimeObserver() : nil
        fullScreenViewController = DTSPlayerFullScreenViewController()
        fullScreenViewController?.player = playerNative
        fullScreenViewController?.showsPlaybackControls = true
        activityViewController.present(fullScreenViewController!, animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fullScreenViewController?.player!.play()
            guard !strongSelf.isLive else { return }
//            strongSelf.configTitle()
            strongSelf.configNextButton()
            if let item = strongSelf.playerNative?.currentItem, let index = strongSelf.playerItems.index(of: item), let timeToSeek = strongSelf.mediaItems[index].watchingTime {
                Alert(message: "Продолжить с \(timeToSeek.timeIntervalAsString("hh:mm:ss"))?")
                    .tint(.kpBlack)
                    .addAction("Нет", style: .cancel)
                    .addAction("Да", style: .default, handler: { (_) in
                        strongSelf.fullScreenViewController?.player?.seek(to: CMTime(seconds: timeToSeek, preferredTimescale: 1))
                    }).show(animated: true)
            }
        }
    }
    
    //Custom Player
    func playWithCustomPlayer(mediaItems: [MediaItem], userinfo: [AnyHashable : Any]? = nil ) {
        playerCustom = EZPlayer()

        playerCustom!.backButtonBlock = { [weak self] fromDisplayMode in
            switch fromDisplayMode {
            case .embedded, .fullscreen, .float:
                self?.releasePlayer()
            default:
                break
            }
        }
        
        guard let url = mediaItems.first?.url else { return }
        playerCustom!.playWithURL(url, embeddedContentView: nil, title: mediaItems.first?.title)

        playerCustom!.fullScreenPreferredStatusBarStyle = .lightContent

        updateDisplayFromDefaults()
        configVolumeView()
    }
    
    @objc func playPauseToggle() {
        guard let player = playerCustom else { return }
        if player.isPlaying {
            player.pause()
            changeMarkTime(force: true)
        } else {
            player.play()
        }
    }

    func releasePlayer() {
        playerCustom?.stop()
        playerCustom?.view.removeFromSuperview()
        playerCustom = nil
        if playerNative == nil {
            mediaItems.removeAll()
        }
        fixReadyToPlay = false
        time = 0
    }
    
    func releaseNativePlayer() {
        if fullScreenViewController != nil {
            fullScreenViewController?.dismiss(animated: true, completion: nil)
            playerNative?.pause()
            mediaItems.removeAll()
            playerItems.removeAll()
            playerNative = nil
            if timeObserver != nil {
                playerNative?.removeTimeObserver(timeObserver!)
                timeObserver = nil
            }
            time = 0
        }
    }

    func configVolumeView() {
        volume = SubtleVolume(style: .plain)
        volume?.frame = CGRect(x: 0, y: 20, width: (playerCustom?.view.frame.size.width)!, height: 2)
        volume?.autoresizingMask = [.flexibleWidth]
        volume?.barTintColor = .kpMarigold
        volume?.animation = .fadeIn
        playerCustom?.view.addSubview(volume!)
    }
    
    func configTitle() {
        if let item = playerNative?.currentItem, let index = playerItems.index(of: item), let title = mediaItems[index].title {
            fullScreenViewController?.configTitle(with: "\(title)")
        }
    }
    
    func configNextButton() {
        if let item = playerNative?.currentItem, var index = playerItems.index(of: item), playerItems.indices.contains(index + 1) {
            index += 1
            let title = "Эпизод \(mediaItems[index].video ?? 0)"
            let image = R.image.play()
            fullScreenViewController?.configNextItemView(with: title, image: image)
        } else {
            fullScreenViewController?.removeNextButton()
        }
    }

    func changeMarkTime(force: Bool = false) {
        guard !isLive else { return }
        guard Config.shared.logViews else { return }
        let _time = Date().timeIntervalSinceReferenceDate
        guard _time - time >= Config.shared.delayViewMarkTime || force else { return }
        if let item = playerNative?.currentItem, let index = playerItems.index(of: item) {
            if let id = mediaItems[index].id, let video = mediaItems[index].video {
                logViewsManager.changeMarktime(id: id, time: (playerNative?.currentTime)!, video: video, season: mediaItems[index].season)
                time = Date().timeIntervalSinceReferenceDate
            }
        } else if playerCustom != nil, let id = mediaItems[0].id, let video = mediaItems[0].video {
            logViewsManager.changeMarktime(id: id, time: (playerCustom?.currentTime)!, video: video, season: mediaItems[0].season)
            time = Date().timeIntervalSinceReferenceDate
        }
    }

    @objc func updateDisplayFromDefaults() {
        playerCustom?.canSlideProgress = Defaults[.canSlideProgress]

        var left: EZPlayerSlideTrigger = .volume
        var right: EZPlayerSlideTrigger = .brightness

        switch Defaults[.leftSlideTrigger] {
        case "none": left = .none
        case "volume": left = .volume
        case "brightness": left = .brightness
        default:  left = .volume
        }
        
        switch Defaults[.rightSlideTrigger] {
        case "none": right = .none
        case "volume": right = .volume
        case "brightness": right = .brightness
        default:  right = .brightness
        }

        playerCustom?.slideTrigger = (left:left, right:right)
    }

    @objc  func playerDidPlayToEnd(_ notifiaction: Notification) {
        changeMarkTime(force: true)
        self.releasePlayer()
        if let item = playerNative?.currentItem, let index = playerItems.index(of: item), index >= playerItems.count - 1 {
            releaseNativePlayer()
        }
        NotificationCenter.default.post(name: .PlayDidFinish, object: self, userInfo:nil)
    }
    
    @objc  func playerDidClosed(_ notifiaction: Notification) {
        changeMarkTime(force: true)
        releaseNativePlayer()
        NotificationCenter.default.post(name: .PlayDidFinish, object: self, userInfo:nil)
    }

    @objc func playerTimeDidChange(_ notifiaction: Notification) {
        changeMarkTime()
    }

    @objc func playerStatusDidChange(_ notifiaction: Notification) {
        guard !fixReadyToPlay else { return }
        if let item = notifiaction.object as? EZPlayer {
            if item.state == .readyToPlay, let timeToSeek = mediaItems.first?.watchingTime {
                fixReadyToPlay = true
                Alert(message: "Продолжить с \(timeToSeek.timeIntervalAsString("hh:mm:ss"))?").tint(.kpBlack)
                .addAction("Нет", style: .cancel)
                .addAction("Да", style: .default, handler: { [weak self] (_) in
                    self?.playerCustom?.seek(to: timeToSeek)
                }).show(animated: true)
            }
        }
    }
    
    @objc func userTappedNextButton(_ notifiaction: Notification) {
//        configTitle()
        configNextButton()
    }
}


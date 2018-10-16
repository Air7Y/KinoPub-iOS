//
//  DetailVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 18/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import LKAlertController

class DetailVC: UIViewController {
    let model = Container.ViewModel.videoItem()
    private let mediaManager = Container.Manager.media
    
    @IBOutlet weak var backroundImageView: UIImageView!
    @IBOutlet var backgroundVisualEffectView: UIVisualEffectView?
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTapped(_ sender: Any) {
        playVideo()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        model.loadItemsInfo()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(modelDidUpdate), name: NSNotification.Name.VideoItemDidUpdate, object: nil)
        
        let focusButtonsGuide = UIFocusGuide()
        view.addLayoutGuide(focusButtonsGuide)
        
        focusButtonsGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        focusButtonsGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        focusButtonsGuide.bottomAnchor.constraint(equalTo: backgroundVisualEffectView!.topAnchor).isActive = true
        
        automaticallyAdjustsScrollViewInsets = false
        tableView.height = UIScreen.main.bounds.height
    }
    
    @objc func modelDidUpdate() {
        button.setTitle("Play", for: UIControl.State.normal)
    }
    
    func playVideo() {
        guard model.mediaItems.first?.url != nil else {
            Helper.showError("Что-то пошло не так")
            return
        }
        mediaManager.playVideo(mediaItems: Config.shared.streamType != "hls4" ? [model.mediaItems.first!] : model.mediaItems, userinfo: nil)
    }
    
    static func storyboardInstance() -> DetailVC? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? DetailVC
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        let height = container.preferredContentSize.height
        tableView.height = UIScreen.main.bounds.height
    }

}

extension DetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = "Cell \(indexPath.row)"
        
        return cell
    }
}

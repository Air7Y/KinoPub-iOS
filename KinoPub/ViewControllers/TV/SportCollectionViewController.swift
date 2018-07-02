//
//  SportCollectionViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 12.02.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import GradientLoadingBar

class SportCollectionViewController: UICollectionViewController, SideMenuItemContent {
    private let model = Container.ViewModel.tv()
    private let mediaManager = Container.Manager.media
    let control = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()
        config()
        configTitle()
        configCollectionView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewLayout(with: size)
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        collectionView?.reloadData()
        GradientLoadingBar.shared.hide()
        control.endRefreshing()
    }
    
    func config() {
        model.delegate = self
        model.loadSportChannels()
    }
    
    @objc func refresh() {
        beginLoad()
        model.loadSportChannels()
    }
    
    func configTitle() {
        title = "Спортивные каналы"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
    }
    
    func configCollectionView() {
        collectionView?.backgroundColor = .kpBackground
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openChannel(_:))))
        // Register cell classes
        if let collectionView = self.collectionView {
            collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 7.0, bottom: 8.0, right: 7.0)
            
            collectionView.register(UINib(nibName: String(describing: TVCollectionViewCell.self), bundle: Bundle.main),
                                    forCellWithReuseIdentifier: String(describing: TVCollectionViewCell.self))
        }
        
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = control
        } else {
            collectionView?.addSubview(control)
        }
    }
    
    func updateCollectionViewLayout(with size: CGSize) {
        if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    // MARK: - Navigation
    @objc func openChannel(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            guard let stream = model.sportChannels[indexPath.row].stream else { return }
            guard let url = URL(string: stream) else { return }
            var mediaItem = MediaItem()
            mediaItem.url = url
            mediaItem.title = model.sportChannels[indexPath.row].title
            mediaManager.playVideo(mediaItems: [mediaItem], isLive: true)
        }
    }
    
    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }

}

// MARK: - UICollectionView DataSource & Delegate
extension SportCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.sportChannels.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TVCollectionViewCell.self), for: indexPath) as! TVCollectionViewCell
        cell.config(withChannel: model.sportChannels[indexPath.row])
        return cell
    }
}

extension SportCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var constant: CGFloat
        let orientation = UIApplication.shared.statusBarOrientation
        if (orientation == .landscapeLeft || orientation == .landscapeRight), UIDevice.current.userInterfaceIdiom == .pad {
            constant = 6.0
        } else if (orientation == .portrait || orientation == .portraitUpsideDown), UIDevice.current.userInterfaceIdiom == .pad {
            constant = 4.0
        } else if orientation == .landscapeLeft || orientation == .landscapeRight {
            constant = 4.0
        } else {
            constant = 2.0
        }
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / constant
        let height = width * 0.796
        return CGSize(width: width, height: height)
    }
}

// MARK: - TVModel Delegate
extension SportCollectionViewController: TVModelDelegate {
    func didUpdateChannels(model: TVModel) {
        endLoad()
    }
}


//
//  ItemsCollectionVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 09.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import DGCollectionViewPaginableBehavior

class ItemsCollectionVC: UICollectionViewController {
    let model = Container.ViewModel.videoItems()
    fileprivate let accountManager = Container.Manager.account
    
    var itemsTag: Int!
    let behavior = DGCollectionViewPaginableBehavior()
    var refreshing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        collectionView?.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        collectionView?.register(UINib(nibName: String(describing: ItemCollectionViewCell.self), bundle: Bundle.main),
                                forCellWithReuseIdentifier: String(describing: ItemCollectionViewCell.self))
        collectionView?.register(UINib(nibName:String(describing:LoadingItemCollectionViewCell.self), bundle: Bundle.main),
                                forCellWithReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier)

        // Do any additional setup after loading the view.
        configView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?.first?.title = "Items"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?.first?.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configView() {
        accountManager.addDelegate(delegate: self)
        model.delegate = self
        collectionView?.backgroundColor = .kpBackground
        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        
        behavior.delegate = self
        behavior.options = DGCollectionViewPaginableBehavior.Options(automaticFetch: true, countPerPage: 20, animatedUpdates: true)
    }
    
    func endLoad() {
        behavior.options.animatedUpdates = false
        collectionView?.reloadData()
    }
    
    @objc func refresh() {
        refreshing = true
        model.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) { [weak self] in
            self?.endLoad()
        }
    }

}

extension ItemsCollectionVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.videoItems.count + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < model.videoItems.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: LoadingItemCollectionViewCell.self), for: indexPath) as! LoadingItemCollectionViewCell
            
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.set(item: model.videoItems[indexPath.row])
        return cell
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if (collectionView?.isFocused)! {
//            collectionView?.image.adjustsImageWhenAncestorFocused = true
            
        } else {
//            collectionView?.image.adjustsImageWhenAncestorFocused = false
        }
    }
}

// MARK: DGCollectionViewPaginableBehaviorDelegate
extension ItemsCollectionVC: DGCollectionViewPaginableBehaviorDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let constant: CGFloat = 7.5
        let width = collectionView.bounds.width / constant
        let height = width * 1.665
        let size = CGSize(width: width.floor, height: height.floor)
        return size
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int {
        return model.countPerPage()
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        model.loadVideoItems { [weak self] (resultCount) in
            guard let strongSelf = self else { return }
            if strongSelf.model.page > strongSelf.model.totalPages {
                completion(nil, 0)
            } else {
                completion(nil, resultCount ?? 0)
            }
        }
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, didAutoFetchDataFor section: Int) {
        
    }
}

// MARK: AccountManager Delegate
extension ItemsCollectionVC: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        refresh()
    }
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {
        refresh()
    }
}

// MARK: VideoItemsModel Delegate
extension ItemsCollectionVC: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        // Forces deinit cells.
        endLoad()
    }
}

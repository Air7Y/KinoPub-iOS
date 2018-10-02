//
//  ItemsVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 16.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class ItemsVC: MediaVC {
    let model = Container.ViewModel.videoItems()
    fileprivate let accountManager = Container.Manager.account
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var filterButton: TVButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        initVars()
        configView()
        model.delegate = self
        accountManager.addDelegate(delegate: self)
    }
    
    func initVars() {
        model.type = ItemType(rawValue: TabBarItemTag(rawValue: 0)!.stringValue)
        setTitles()
    }
    
    func configView() {
        titleLabel.textColor = .kpOffWhite
        subTitleLabel.textColor = .kpGreyishTwo
    }
    
    func setTitles() {
        guard let title = model.type?.description else { return }
        titleLabel.text = title
        subTitleLabel.text = "Все " + title.lowercased()
    }

    func refreshData() {
        collectionViewController.dataSources[0] = []
        model.refresh()
        collectionViewController.refresh()
    }
    
    override func load(forCollectionView collectionView: UICollectionView, completion: @escaping (Int) -> ()) {
        if collectionView == collectionViewController.collectionView {
            model.loadVideoItems { [weak self] (count, error) in
                guard let strongSelf = self else { return }
                let done = strongSelf.model.page > strongSelf.model.totalPages
                strongSelf.collectionViewController.error = error as NSError?
                completion(done ? 0 : count ?? 0)
            }
        }
    }
    
    override func itemSize(forCellIn collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize? {
        if collectionView == menuCollectionVC.collectionView {
            let size = MenuItems.atvMenu[indexPath.row].name.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30.0)])
            return CGSize(width: 80 + size.width, height: 70)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets? {
        if collectionView == collectionViewController.collectionView {
            return UIEdgeInsets(top: 50, left: 100, bottom: 0, right: 100)
        } else if collectionView == menuCollectionVC.collectionView {
            return UIEdgeInsets(top: 20, left: 100, bottom: 25, right: 100)
        }
        return nil
    }
    
    override func countPerPage(in section: Int) -> Int {
        return model.countPerPage()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewController.collectionView {
            guard indexPath.row < model.videoItems.count else { return }
            if let detailVC = DetailVC.storyboardInstance() {
                
                navigationController?.show(detailVC, sender: self)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        didUpdateFocusIn(context)
        
        if collectionView == menuCollectionVC.collectionView {
            guard let item = context.nextFocusedItem, item is MenuItemCollectionViewCell else { return }
            guard context.previouslyFocusedIndexPath != nil else { return }
            guard let tag = MenuItems.atvMenu[menuCollectionVC.focusIndexPath.row].tag else { return }
            guard let itemType = ItemType(rawValue: tag.stringValue) else { return }

            model.type = itemType
            setTitles()
            
            if let data = model.videoItemsDict[itemType.rawValue] {
                collectionViewController.dataSources[0] = data
                collectionViewController.collectionView?.reloadSections([0])
            } else {
                refreshData()
            }
            
        }
    }
    
    func didUpdateFocusIn(_ context: UICollectionViewFocusUpdateContext) {
        (context.nextFocusedItem as? MenuItemCollectionViewCell)?.focusedView()
        (context.previouslyFocusedItem as? MenuItemCollectionViewCell)?.unfocusedView()
    }
    
}

// MARK: AccountManager Delegate
extension ItemsVC: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        refreshData()
    }
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {
        refreshData()
    }
}

// MARK: VideoItemsModel Delegate
extension ItemsVC: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        defer { collectionViewController.dataDidLoaded() }
        guard let index = model.type?.rawValue, let data = model.videoItemsDict[index] else { return }
        collectionViewController.dataSources[0] = data as [AnyHashable]
    }
}

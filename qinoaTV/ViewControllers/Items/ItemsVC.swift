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

    override func viewDidLoad() {
        super.viewDidLoad()

        model.delegate = self
        accountManager.addDelegate(delegate: self)
    }

    func refreshData() {
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
        } else if collectionView == menuCollectionVC.collectionView {
            menuCollectionVC.dataSources[0] = MenuItems.atvMenu as [AnyHashable]
            menuCollectionVC.dataDidLoaded()
            completion(MenuItems.atvMenu.count)
//            menuCollectionVC.focusIndexPath = IndexPath(row: 0, section: 0)
        }
    }
    
    override func itemSize(forCellIn collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize? {
        if collectionView == menuCollectionVC.collectionView {
            let size = MenuItems.atvMenu[indexPath.row].name.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30.0)])
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
        if collectionView == menuCollectionVC.collectionView {
            guard let item = context.nextFocusedItem, item is MenuItemCollectionViewCell else { return }
            print(menuCollectionVC.focusIndexPath)
            guard let tag = MenuItems.atvMenu[menuCollectionVC.focusIndexPath.row].tag else { return }
            model.setParameter("genre", value: nil)
            switch tag {
            case TabBarItemTag.movies.rawValue:
                model.type = ItemType.movies
                navigationItem.title = ItemType.movies.description
            case TabBarItemTag.shows.rawValue:
                model.type = ItemType.shows
                navigationItem.title = ItemType.shows.description
            case TabBarItemTag.documovie.rawValue:
                model.type = ItemType.documovie
                navigationItem.title = ItemType.documovie.description
            case TabBarItemTag.docuserial.rawValue:
                model.type = ItemType.docuserial
                navigationItem.title = ItemType.docuserial.description
            case TabBarItemTag.concert.rawValue:
                model.type = ItemType.concerts
                navigationItem.title = ItemType.concerts.description
            case TabBarItemTag.tvshow.rawValue:
                model.type = ItemType.tvshows
                navigationItem.title = ItemType.tvshows.description
            case TabBarItemTag.cartoons.rawValue:
                model.setParameter("genre", value: "23")
                navigationItem.title = "Мультфильмы"
            case TabBarItemTag.movies4k.rawValue:
                model.type = ItemType.movies4k
                navigationItem.title = ItemType.movies4k.description
            case TabBarItemTag.movies3d.rawValue:
                model.type = ItemType.movies3d
                navigationItem.title = ItemType.movies3d.description
            default:
                break
            }
            refreshData()
        }
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
        collectionViewController.dataSources[0] = model.videoItems as [AnyHashable]
        collectionViewController.dataDidLoaded()
    }
}

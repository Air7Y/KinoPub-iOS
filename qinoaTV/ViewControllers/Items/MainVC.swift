//
//  MainVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 13.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class MainVC: UIViewController, CollectionVCDelegate {
    
    var collectionViewController: CollectionVC!
    var menuCollectionVC: CollectionVC!
    
    var collectionView: UICollectionView? {
        get {
            return collectionViewController?.collectionView
        } set(newObject) {
            collectionViewController?.collectionView = newObject
        }
    }
    
    var environmentsToFocus: [UIFocusEnvironment] = []
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return environmentsToFocus.isEmpty ? super.preferredFocusEnvironments : environmentsToFocus
    }

    override dynamic func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kpBackground
    }
    
    override dynamic func viewWillAppear(_ animated: Bool) {
        if self.view.bounds != (super.navigationController?.view?.bounds)! {
            self.view.bounds = (super.navigationController?.view?.bounds)!
        }
        super.viewWillAppear(animated)
    }
    
    override dynamic func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        setNeedsFocusUpdate()
//        updateFocusIfNeeded()
//        
//        environmentsToFocus.removeAll()
//        
//        collectionView?.setNeedsFocusUpdate()
//        collectionView?.updateFocusIfNeeded()
//        
//        collectionView?.reloadData()
    }
    
    // CollectionVCDelegate Methods
    func load(forCollectionView collectionView: UICollectionView, completion: @escaping (Int) -> ()) {}
    func countPerPage(in section: Int) -> Int { return 20 }
    
    func itemSize(forCellIn collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize? { return nil }
    func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets? { return nil }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {}
    
    // MARK: - Navigation
    #if os(tvOS)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segue = R.segue.itemsVC.embed(segue: segue) {
            collectionViewController = segue.destination
            collectionViewController.delegate = self
            #if os(iOS)
                collectionViewController.isRefreshable = true
            #endif
        } else if let segue = R.segue.itemsVC.embedMenu(segue: segue) {
            menuCollectionVC = segue.destination
//            menuCollectionVC.focusIndexPath = IndexPath(row: 0, section: 0)
            menuCollectionVC.delegate = self
        }
    }
    #endif
}

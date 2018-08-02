//
//  ItemsCollectionVC.swift
//  qinoaTV
//
//  Created by Евгений Дац on 09.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import DGCollectionViewPaginableBehavior
import Rswift

protocol CellCustomizing {
    func configureCell<T>(with item: T)
}

protocol CollectionVCDelegate: class {
    func load(forCollectionView collectionView: UICollectionView, completion: @escaping (_ count: Int) -> ())
    func countPerPage(in section: Int) -> Int
    
    func didRefresh(collectionView: UICollectionView)
    func collectionView(isEmptyForUnknownReason collectionView: UICollectionView)
    
    func itemSize(forCellIn collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize?
    func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
}

extension CollectionVCDelegate {
    func load(forCollectionView collectionView: UICollectionView, completion: @escaping (_ count: Int) -> ()) {}
    func countPerPage(in section: Int) -> Int { return 20 }
    
    func didRefresh(collectionView: UICollectionView) {}
    func collectionView(isEmptyForUnknownReason collectionView: UICollectionView) {}
    
    func itemSize(forCellIn collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize? { return nil }
    func collectionView(_ collectionView: UICollectionView, insetForSectionAt section: Int) -> UIEdgeInsets? { return nil }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {}
}

class CollectionVC: ResponsiveCollectionVC {
    
    weak var delegate: CollectionVCDelegate?
    
    var dataSources: [[AnyHashable]] = [[]]
    var error: NSError?
    
    let behavior = DGCollectionViewPaginableBehavior()
    var refreshing: Bool = false
    
    fileprivate var errorView: ErrorBackgroundView?
    
    var activeRootViewController: MainVC? {
        guard
            let navigationController = tabBarController?.selectedViewController as? UINavigationController,
            let main = navigationController.viewControllers.compactMap({$0 as? MainVC}).first
            else {
                return nil
        }
        return main
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        configCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateNavigationItemOffset()
    }
    
    func updateNavigationItemOffset() {
        guard let collectionView = collectionView else { return }
        
        let adjustment = collectionView.contentOffset.y + collectionView.contentInset.top - 44
        parent?.navigationItem.leftBarButtonItem?.customView?.frame.origin.y = -adjustment
        parent?.navigationItem.rightBarButtonItems?.forEach({$0.customView?.frame.origin.y = -adjustment})
    }
    
    func configCollectionView() {
        collectionView?.remembersLastFocusedIndexPath = true
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        }
        collectionView?.backgroundColor = .kpBackground
//        collectionView?.contentInset = UIEdgeInsets(top: 30, left: 90, bottom: 0, right: 90)
        
        collectionView?.register(R.nib.itemCollectionViewCell)
        collectionView?.register(R.nib.loadingItemCollectionViewCell)
        #if os(tvOS)
        collectionView?.register(R.nib.menuItemCollectionViewCell)
        #endif
        
        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        
        behavior.delegate = self
        behavior.options = DGCollectionViewPaginableBehavior.Options(automaticFetch: true, countPerPage: 20, animatedUpdates: true)
    }
    
    func dataDidLoaded() {
        behavior.options.animatedUpdates = false
        refreshing = false
        collectionView?.reloadData()
    }
    
    @objc func refresh() {
        refreshing = true
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) { [weak self] in
            self?.dataDidLoaded()
        }
    }
    
//    override func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewFlowLayout, didChangeToSize size: CGSize) {
//        let itemSize = self.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath(item: 0, section: 0))
//        super.collectionView(collectionView, layout: layout, didChangeToSize: CGSize(width: size.width, height: itemSize.height))
//    }
    
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        return activeRootViewController
    }

}

extension CollectionVC {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.backgroundView = nil
        guard dataSources.flatMap({$0}).isEmpty else {
            error = nil
            return dataSources.count
        }
        
        if let error = error {
            errorView = ErrorBackgroundView.fromNib()
            errorView?.configView(error: error)
            errorView?.delegate = self
            collectionView.backgroundView = errorView
        } else {
            delegate?.collectionView(isEmptyForUnknownReason: collectionView)
        }
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (dataSources[safe: section]?.count ?? 0) + (behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < dataSources[safe: indexPath.section]?.count ?? 0 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.loadingItemCollectionViewCell, for: indexPath)!
            
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let item = dataSources[indexPath.section][indexPath.row]
        switch item {
        case is Item:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.itemCollectionViewCell, for: indexPath)!
            cell.configureCell(with: item)
            return cell
        case is MenuItems:
            #if os(tvOS)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.menuItemCollectionViewCell, for: indexPath)!
            cell.configureCell(with: item)
            return cell
            #endif
        default:
            fatalError("Unknown type in dataSource.")
        }

        return UICollectionViewCell()
    }
    
}

// MARK: DGCollectionViewPaginableBehaviorDelegate
extension CollectionVC: DGCollectionViewPaginableBehaviorDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = delegate?.itemSize(forCellIn: collectionView, at: indexPath) { return size }
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        
        var constant: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        let sectionInset = flowLayout.scrollDirection == .vertical ? (flowLayout.sectionInset.left + flowLayout.sectionInset.right) : (flowLayout.sectionInset.top + flowLayout.sectionInset.bottom)
        let spacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
        if flowLayout.scrollDirection == .vertical {
            constant = 6
            width = (collectionView.bounds.width - sectionInset - spacing) / constant
            height = width * 1.5 + 85
        } else {
            constant = 1
            height = (collectionView.bounds.height - sectionInset - spacing) / constant
            width = (height - 85) / 1.5
        }
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if let dataSource = dataSources[safe: section], !dataSource.isEmpty {
            if let inset = delegate?.collectionView(collectionView, insetForSectionAt: section) { return inset }
            let isTv = UIDevice.current.userInterfaceIdiom == .tv
            return isTv ? UIEdgeInsets(top: 50, left: 100, bottom: 0, right: 100) : UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        
        return .zero
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int {
        return delegate?.countPerPage(in: section) ?? 20
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        delegate?.load(forCollectionView: collectionView!, completion: { (count) in
            completion(nil, count)
        })
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, scrollViewDidScroll scrollView: UIScrollView) {
        updateNavigationItemOffset()
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        focusIndexPath = indexPath
        delegate?.collectionView(collectionView, didSelectItemAt: indexPath)
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let next = context.nextFocusedIndexPath {
            focusIndexPath = next
        }
        delegate?.collectionView(collectionView, didUpdateFocusIn: context, with: coordinator)
    }
    
    func indexPathForPreferredFocusedViewIn(_ collectionView: UICollectionView) -> IndexPath? {
        return focusIndexPath
    }
}

extension CollectionVC: ErrorBackgroundViewDelegate {
    func updateButtonDidTappedInErrorView(_ sender: Any) {
        error = nil
        refresh()
    }
}

extension CollectionVC {
    private struct AssociatedKeys {
        static var focusIndexPathKey = "CollectionViewController.focusIndexPathKey"
    }
    
    var focusIndexPath: IndexPath {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.focusIndexPathKey) as? IndexPath ?? IndexPath(item: 0, section: 0)
        } set (indexPath) {
            objc_setAssociatedObject(self, &AssociatedKeys.focusIndexPathKey, indexPath, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
//    override func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
//        return focusIndexPath
//    }
}

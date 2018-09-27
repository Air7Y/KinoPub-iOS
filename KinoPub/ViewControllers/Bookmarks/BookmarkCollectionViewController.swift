//
//  BookmarkCollectionViewController.swift
//  KinoPub
//
//  Created by hintoz on 11.06.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import DGCollectionViewPaginableBehavior
import LKAlertController
import CustomLoader
import UIEmptyState
import GradientLoadingBar

class BookmarkCollectionViewController: ContentCollectionViewController {
    let viewModel = Container.ViewModel.bookmarks()
    
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    var refreshing: Bool = false
    var editingFolder: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()
        configView()
        configEmptyCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillLayoutSubviews() {
        for cell in (collectionView?.visibleCells)! {
            (cell as? ItemCollectionViewCell)?.editBookmarkView.isHidden = !editingFolder
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configView() {
        title = viewModel.folder?.title
        collectionView?.backgroundColor = UIColor.kpBackground
        collectionView?.tintColor = UIColor.kpOffWhite
        viewModel.delegate = self
        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        behavior.delegate = self
        behavior.options = DGCollectionViewPaginableBehavior.Options(automaticFetch: true, countPerPage: 20, animatedUpdates: true)
        
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = control
        } else {
            collectionView?.addSubview(control)
        }
    }
    
    func configEmptyCollection() {
        emptyStateDataSource = self
        emptyStateDelegate = self
        reloadEmptyStateForCollectionView(collectionView!)
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        behavior.options.animatedUpdates = false
        collectionView?.reloadData()
        reloadEmptyStateForCollectionView(collectionView!)
        GradientLoadingBar.shared.hide()
        control.endRefreshing()
    }
    
    @objc func refresh() {
        beginLoad()
        refreshing = true
        viewModel.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) { [weak self] in
            self?.endLoad()
        }
    }
    
    @objc func tap(sender: UITapGestureRecognizer) {
        guard !editingFolder else { return }
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: viewModel.items[indexPath.row], andImage: image)
                }
            }
        }
    }
    
    func showDetailVC(with item: Item, andImage image: UIImage) {
        if let detailViewController = DetailViewController.storyboardInstance() {
            detailViewController.image = image
            detailViewController.model.item = item
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    func removeFromBookmark(item: Item, indexPath: IndexPath) {
        guard let itemId = item.id?.string else { return }
        guard let folderId = viewModel.folder?.id.string else { return }
        viewModel.items.remove(at: indexPath.row)
        collectionView?.deleteItems(at: [indexPath])
        viewModel.removeItemFromFolder(item: itemId, folder: folderId)
        endLoad()
    }
    
    func loadItemFolders(_ indexPath: IndexPath) {
        let cell = collectionView?.cellForItem(at: indexPath) as! ItemCollectionViewCell
        guard let itemId = viewModel.items[indexPath.row].id else { return }
        _ = LoadingView.system(withStyle: .white).show(inView: cell.moveFromBookmarkButton)
        viewModel.getItemFolders(item: itemId.string) { [weak self] (bookmarks) in
            defer { cell.moveFromBookmarkButton.removeLoadingViews(animated: true) }
            guard let folders = bookmarks else { return }
            self?.showBookmarkFolders(indexPath, folders: folders)
        }
    }
    
    func showBookmarkFolders(_ indexPath: IndexPath, folders: [Bookmarks]) {
        let cell = collectionView?.cellForItem(at: indexPath) as! ItemCollectionViewCell
        guard let itemId = viewModel.items[indexPath.row].id else { return }
        _ = LoadingView.system(withStyle: .white).show(inView: cell.moveFromBookmarkButton)
        viewModel.loadBookmarks { [weak self] (bookmarks) in
            guard let strongSelf = self else { return }
            defer {
                if #available(iOS 10.0, *) { Helper.hapticGenerate(style: .medium) }
                cell.moveFromBookmarkButton.removeLoadingViews(animated: true)
            }
            guard var bookmarks = bookmarks else { return }
            bookmarks = bookmarks.filter { !folders.contains($0) }
            guard !bookmarks.isEmpty else {
                strongSelf.showNewFolderAlert(indexPath)
                return
            }
            
            let action = ActionSheet(message: "Выберите папку", blurStyle: .dark).tint(.kpOffWhite)
            action.addAction("+ Новая папка", style: .default, handler: { (_) in
                strongSelf.showNewFolderAlert(indexPath)
            })
            for folder in bookmarks {
                action.addAction(folder.title!, style: .default, handler: { (_) in
                    strongSelf.viewModel.toggleItemToFolder(item: itemId.string, folder: folder.id.string)
                    strongSelf.removeFromBookmark(item: strongSelf.viewModel.items[indexPath.row], indexPath: indexPath)
                })
            }
            action.addAction("Отмена", style: .cancel)
            action.setPresentingSource(cell.moveFromBookmarkButton)
            action.show()
        }
    }
    
    func showNewFolderAlert(_ indexPath: IndexPath) {
        var textField = UITextField()
        textField.placeholder = "Название"
        Alert(title: "Новая папка", message: "Придумайте короткое и ёмкое название для новой папки", blurStyle: .dark).tint(.kpOffWhite).textColor(.kpOffWhite)
            .addTextField(&textField)
            .addAction("Отмена", style: .cancel)
            .addAction("Создать", style: .default, preferredAction: true) { [weak self] (action) in
                guard let strongSelf = self else { return }
                guard let text = textField.text else { return }
                strongSelf.viewModel.createBookmarkFolder(title: text, completed: { (bookmark) in
                    guard let itemId = strongSelf.viewModel.items[indexPath.row].id else { return }
                    guard let bookmarkId = bookmark?.id else { return }
                    strongSelf.viewModel.toggleItemToFolder(item: itemId.string, folder: bookmarkId.string)
                    strongSelf.removeFromBookmark(item: strongSelf.viewModel.items[indexPath.row], indexPath: indexPath)
                })
            }
            .show(animated: true)
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: editingFolder ? .edit : .done, target: self, action: #selector(editButtonTapped(_:)))
        navigationItem.rightBarButtonItem?.tintColor = editingFolder ? .kpOffWhite : .kpMarigold
        editingFolder.toggle()
        
        collectionView?.setNeedsLayout()
    }
    
    // MARK: - Navigation

    static func storyboardInstance() -> BookmarkCollectionViewController? {
        let storyboard = UIStoryboard(name: "Bookmarks", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? BookmarkCollectionViewController
    }
    
    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension BookmarkCollectionViewController: ItemCollectionViewCellDelegate {
    func didPressDeleteButton(_ item: Item) {
        guard let index = viewModel.items.index(where: { $0 === item }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        Alert(message: "Удалить?", blurStyle: .dark).tint(.kpOffWhite).textColor(.kpOffWhite)
            .addAction("Отмена", style: .cancel)
            .addAction("Да", style: .default, handler: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.removeFromBookmark(item: strongSelf.viewModel.items[indexPath.row], indexPath: indexPath)
            })
            .show()
        if #available(iOS 10.0, *) { Helper.hapticGenerate(style: .medium) }
    }
    
    func didPressMoveButton(_ item: Item) {
        guard let index = viewModel.items.index(where: { $0 === item }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        loadItemFolders(indexPath)
    }
}

// MARK: UICollectionViewDataSource
extension BookmarkCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return (viewModel.items.count) + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < viewModel.items.count else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingItemCollectionViewCell.reuseIdentifier, for: indexPath) as! LoadingItemCollectionViewCell
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        cell.set(item: viewModel.items[indexPath.row])
        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension BookmarkCollectionViewController {
    
}

extension BookmarkCollectionViewController: DGCollectionViewPaginableBehaviorDelegate {
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
        let height = width * 1.569
        return CGSize(width: width, height: height)
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int {
        return 20
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        viewModel.loadBookmarkItems { [weak self] (count) in
            guard let strongSelf = self else { return }
            if strongSelf.viewModel.page > strongSelf.viewModel.totalPages {
                completion(nil, 0)
            } else {
                completion(nil, count ?? 0)
            }
        }
    }

    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, didAutoFetchDataFor section: Int) {
        reloadEmptyStateForCollectionView(collectionView!)
    }
}

extension BookmarkCollectionViewController: UIEmptyStateDelegate, UIEmptyStateDataSource {
    // MARK: - Empty State Data Source
    var emptyStateImage: UIImage? {
        return UIImage(named: "Folder")?.filled(withColor: UIColor.kpGreyishTwo)
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.kpOffWhite,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        return NSAttributedString(string: "Здесь будет храниться ваш контент, который вы добавите в папку.", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.black,
                     NSAttributedString.Key.font: UIFont.init(name: "UniSansSemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12)]
        return NSAttributedString(string: "ОБНОВИТЬ", attributes: attrs)
    }
    
    var emptyStateButtonSize: CGSize? {
        return CGSize(width: 200, height: 36)
    }
    
    // MARK: - Empty State Delegate
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }
        emptyView.button.layer.cornerRadius = 4
        emptyView.button.layer.backgroundColor = UIColor.kpMarigold.cgColor
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        if #available(iOS 10.0, *) { Helper.hapticGenerate(style: .medium) }
        refresh()
    }
}

extension BookmarkCollectionViewController: BookmarksModelDelegate {
    func didUpdateItems(model: BookmarksModel) {
        endLoad()
    }
}

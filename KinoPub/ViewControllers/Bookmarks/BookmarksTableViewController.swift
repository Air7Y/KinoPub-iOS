//
//  BookmarksTableViewController.swift
//  KinoPub
//
//  Created by hintoz on 11.06.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import CustomLoader
import LKAlertController
import InteractiveSideMenu
import UIEmptyState
import GradientLoadingBar

class BookmarksTableViewController: UITableViewController, SideMenuItemContent {
    let viewModel = Container.ViewModel.bookmarks()
    
    let control = UIRefreshControl()
    var tableViewFooter: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()
        configView()
        configHint()
        loadContent()
        configEmptyTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configView() {
        viewModel.delegate = self
        title = "Закладки"
        
        tableView.register(UINib(nibName: String(describing: BookmarkTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: BookmarkTableViewCell.self))
        tableView.backgroundColor = .kpBackground
        tableView.tintColor = UIColor.kpGreyishTwo
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
        
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = control
        } else {
            tableView?.addSubview(control)
        }
    }
    
    func configEmptyTable() {
        emptyStateDataSource = self
        emptyStateDelegate = self
        reloadEmptyStateForTableView(tableView)
    }
    
    func configHint() {
        tableViewFooter = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 66))
        tableViewFooter.backgroundColor = .clear
        let label = UILabel(frame: CGRect(x: 15, y: 10, width: tableView.frame.width - 30, height: 46))
        label.font = label.font.withSize(12)
        label.text = "Для удаления папки просто проведите по ней справа налево. Также вы можете переносить фильмы из одной папки в другую."
        label.numberOfLines = 0
        label.textColor = UIColor.kpGreyishBrown
        label.textAlignment = .left
        
        tableViewFooter.addSubview(label)
        
//        tableView.tableFooterView = tableViewFooter
    }
    
    func loadContent() {
        viewModel.loadBookmarks { [weak self] (_) in
            self?.endLoad()
        }
    }
    
    @objc func refresh() {
        beginLoad()
        loadContent()
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        tableView.reloadData()
        reloadEmptyStateForTableView(tableView)
        tableView.tableFooterView = viewModel.bookmarks.isEmpty ? UIView(frame: .zero) : tableViewFooter
        GradientLoadingBar.shared.hide()
        control.endRefreshing()
    }
    
    func showNewFolderAlert() {
        var textField = UITextField()
        textField.placeholder = "Название"
        Alert(title: "Новая папка", message: "Придумайте короткое и ёмкое название для новой папки")
            .tint(.kpBlack)
        .addTextField(&textField)
            .addAction("Отмена", style: .cancel)
        .addAction("Создать", style: .default, preferredAction: true) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.createBookmarkFolder(title: textField.text!)
        }
        .show(animated: true)
    }

    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }
    
    @IBAction func addFolderButtonTapped(_ sender: UIBarButtonItem) {
        Helper.hapticGenerate(style: .medium)
        showNewFolderAlert()
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

// MARK: - Table view data source
extension BookmarksTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BookmarkTableViewCell.self), for: indexPath) as! BookmarkTableViewCell
        
        cell.config(withBookmark: viewModel.bookmarks[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let bookmarkCollectionVC = BookmarkCollectionViewController.storyboardInstance() {
            bookmarkCollectionVC.viewModel.folder = viewModel.bookmarks[indexPath.row]
            navigationController?.pushViewController(bookmarkCollectionVC, animated: true)
        }
    }
}

// MARK: able view delegate
extension BookmarksTableViewController {
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { [weak self] (_, indexPath) in
            guard let strongSelf = self else { return }
            guard let folder = strongSelf.viewModel.bookmarks[indexPath.row].id else { return }
            strongSelf.viewModel.bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            strongSelf.viewModel.removeBookmarkFolder(folder: String(folder))
        }
        
        deleteAction.backgroundColor = .kpGreyishTwo
        
        return [deleteAction]
    }
}

extension BookmarksTableViewController: BookmarksModelDelegate {
    func didUpdateBookmarks(model: BookmarksModel) {
        refresh()
    }
    func didAddedBookmarks() {
        refresh()
    }
}

extension BookmarksTableViewController: UIEmptyStateDelegate, UIEmptyStateDataSource {
    // MARK: - Empty State Data Source
    var emptyStateImage: UIImage? {
        return UIImage(named: "Folder")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
        return NSAttributedString(string: "Здесь будут отображаться ваши папки. Создайте первую, нажав на кнопку ниже.", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont.init(name: "UniSansSemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12)]
        return NSAttributedString(string: "СОЗДАТЬ", attributes: attrs)
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
        Helper.hapticGenerate(style: .medium)
        showNewFolderAlert()
    }
}


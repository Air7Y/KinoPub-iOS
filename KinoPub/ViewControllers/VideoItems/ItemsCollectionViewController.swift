//
//  ItemsCollectionViewController.swift
//  KinoPub
//
//  Created by hintoz on 06.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import DGCollectionViewPaginableBehavior
import AZSearchView
import InteractiveSideMenu
import GradientLoadingBar
import UIEmptyState

class ItemsCollectionViewController: ContentCollectionViewController, SideMenuItemContent {
    let model = Container.ViewModel.videoItems()
    fileprivate let accountManager = Container.Manager.account

    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
//    @IBOutlet weak var typeWatchlistSegmentedControl: UISegmentedControl!
    
//    var type: ItemType? {
//        didSet {
//            model.type = type
//        }
//    }
    var itemsTag: Int!
    let behavior = DGCollectionViewPaginableBehavior()
    let control = UIRefreshControl()
    
    var searchController: AZSearchViewController!
    var searchControllerNew: UISearchController!
    
    var refreshing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()
        configView()
        configOldSearch()
        configNewSearch()
        configMenuIcon()
        configTabBar()
        configEmptyCollection()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        filterButton?.image = model.filter.isSet ? R.image.filtersFill() : R.image.filters()
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        collectionView?.reloadData()
        reloadEmptyStateForCollectionView(collectionView!)
        GradientLoadingBar.shared.hide()
        control.endRefreshing()
    }

    @objc func refresh() {
        beginLoad()
        refreshing = true
        searchControllerNew.isActive ? model.refreshSearch() : model.refresh()
        refreshing = false
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) { [weak self] in
            self?.endLoad()
        }
        control.endRefreshing()
    }
    
    func configView() {
        accountManager.addDelegate(delegate: self)
        model.delegate = self
        collectionView?.backgroundColor = .kpBackground
        collectionView?.delegate = behavior
        collectionView?.dataSource = self
        
        if #available(iOS 10.0, *) {
            collectionView?.isPrefetchingEnabled = false
        }
        
        behavior.delegate = self
        behavior.options = DGCollectionViewPaginableBehavior.Options(automaticFetch: true, countPerPage: 20, animatedUpdates: true)
        collectionView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
        // Pull to refresh
        control.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        control.tintColor = UIColor.kpOffWhite
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = control
        } else {
            collectionView?.addSubview(control)
        }
    }

    func configTabBar() {
        switch itemsTag {
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
        case TabBarItemTag.collections.rawValue:
            model.configFrom("collections")
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem = nil
        case TabBarItemTag.watchlist.rawValue:
            model.configFrom("watching")
            navigationItem.title = "Я смотрю"
            navigationItem.rightBarButtonItems = nil
        case TabBarItemTag.cartoons.rawValue:
            model.setParameter("genre", value: "23")
            navigationItem.title = "Мультфильмы"
        case TabBarItemTag.movies4k.rawValue:
            model.type = ItemType.movies4k
            navigationItem.title = ItemType.movies4k.description
        case TabBarItemTag.movies3d.rawValue:
            model.type = ItemType.movies3d
            navigationItem.title = ItemType.movies3d.description
        case TabBarItemTag.newMovies.rawValue:
            navigationItem.title = TabBarItemTag.newMovies.description
            model.type = ItemType.movies
            model.filter.sort = SortOption.created
        case TabBarItemTag.newSeries.rawValue:
            navigationItem.title = TabBarItemTag.newSeries.description
            model.type = ItemType.shows
            model.filter.sort = SortOption.created
        case TabBarItemTag.hotMovies.rawValue:
            navigationItem.title = TabBarItemTag.hotMovies.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.movies
            model.from = "hot"
        case TabBarItemTag.hotSeries.rawValue:
            navigationItem.title = TabBarItemTag.hotSeries.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.shows
            model.from = "popular"
        case TabBarItemTag.freshMovies.rawValue:
            navigationItem.title = TabBarItemTag.freshMovies.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.movies
            model.from = "fresh"
        case TabBarItemTag.freshSeries.rawValue:
            navigationItem.title = TabBarItemTag.freshSeries.description
            navigationItem.rightBarButtonItems?[0].customView = UIView()
            model.type = ItemType.shows
            model.from = "fresh"
        default:
            break
        }
    }

    func configOldSearch() {
        searchController = AZSearchViewController(cellReuseIdentifier: String(describing: SearchResultTableViewCell.self),
                                                  cellNibName: String(describing: SearchResultTableViewCell.self))
        searchController.delegate = self
        searchController.dataSource = self
        searchController.searchBarPlaceHolder = "Поиск"
        searchController.navigationBarClosure = { bar in
            //The navigation bar's background color
            bar.barTintColor = .kpBackground
            bar.isTranslucent = false
            //The tint color of the navigation bar
            bar.tintColor = .kpOffWhite
        }
        searchController.emptyResultCellTextColor = .kpOffWhite
        searchController.minimalCharactersForSearch = 2
        searchController.infoCellText = "Введите более 2-х символов для поиска"
        searchController.emptyResultCellText = "Нет результатов поиска"
        searchController.searchBarBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.05)
        searchController.searchBarTextColor = .kpOffWhite
        searchController.keyboardAppearnce = .dark
        searchController.separatorColor = .kpOffWhiteSeparator
        searchController.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        searchController.tableViewBackgroundColor = .kpBackground //UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeSearchBar(_:)))
        item.tintColor = .kpMarigold
        searchController.navigationItem.rightBarButtonItem = item
    }
    
    func configNewSearch() {
        searchControllerNew = UISearchController(searchResultsController: nil)
        searchControllerNew.searchBar.tintColor = .kpOffWhite
        searchControllerNew.searchBar.placeholder = "Поиск"
        searchControllerNew.searchBar.keyboardAppearance = .dark
        
        if #available(iOS 11.0, *) {
            navigationItem.rightBarButtonItems = [filterButton]
            searchControllerNew.dimsBackgroundDuringPresentation = true
            searchControllerNew.obscuresBackgroundDuringPresentation = false
            searchControllerNew.searchBar.sizeToFit()
            searchControllerNew.searchResultsUpdater = self
            searchControllerNew.searchBar.delegate = self
            searchControllerNew.hidesNavigationBarDuringPresentation = true
            navigationItem.searchController = searchControllerNew
            definesPresentationContext = true
        } else {
            navigationItem.rightBarButtonItems = [filterButton, searchButton]
        }
    }
    
    func configMenuIcon() {
        if let count = navigationController?.viewControllers.count, count > 1 {
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    func configEmptyCollection() {
        emptyStateDataSource = self
        emptyStateDelegate = self
        reloadEmptyStateForCollectionView(collectionView!)
    }

    // MARK: - Buttons

    @IBAction func showSearchButtonTapped(_ sender: UIBarButtonItem) {
        searchController.show(in: self)
//        if navigationItem.titleView == nil {
//            navigationItem.titleView = searchControllerNew.searchBar
//        } else {
//            searchControllerNew.searchBar.clear()
//            searchControllerNew.dismiss(animated: true, completion: nil)
//            navigationItem.titleView = nil
//        }
    }

    @objc func closeSearchBar(_ sender: AnyObject?) {
        searchController.dismiss(animated: true)
    }

    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        if let fvc = FilterViewController.storyboardInstance() {
            fvc.model.type = model.type
            fvc.model.filter = model.filter
            navigationController?.pushViewController(fvc, animated: true)
        }
    }
    
    @IBAction func typeWatchlistSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            model.configFrom("watching")
            refresh()
        case 1:
            model.configFrom("usedMovie")
            refresh()
        default:
            break
        }
    }
    
    func filterBack() {
        refresh()
    }
    
    // MARK: - Navigation
    static func storyboardInstance() -> ItemsCollectionViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? ItemsCollectionViewController
    }

    @objc func tap(sender: UITapGestureRecognizer) {
        guard (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) > 0 else { return }
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            if let cell = collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: searchControllerNew.isActive ? model.resultItems[indexPath.row] : model.videoItems[indexPath.row], andImage: image)
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
    
    // MARK: - Orientations
    override var shouldAutorotate: Bool {
        return true
    }
    
    // MARK: - StatusBar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UICollectionViewDataSource
extension ItemsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) + (self.behavior.sectionStatus(forSection: section).done ? 0 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < (searchControllerNew.isActive ? model.resultItems.count : model.videoItems.count) else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.loadingItemCollectionViewCell, for: indexPath)!
            
            if !self.refreshing {
                cell.set(moreToLoad: !self.behavior.sectionStatus(forSection: indexPath.section).done)
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.itemCollectionViewCell, for: indexPath)!
        cell.set(item: searchControllerNew.isActive ? model.resultItems[indexPath.row] : model.videoItems[indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView!
        if (kind == UICollectionElementKindSectionHeader) {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCell", for: indexPath)
            reusableView = cell
        }
        if (kind == UICollectionElementKindSectionFooter) {
            reusableView = nil
        }
        
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if itemsTag == TabBarItemTag.watchlist.rawValue, !searchControllerNew.isActive {
            return CGSize(width: collectionView.width, height: 50)
        }
        return CGSize.zero
    }
}

// MARK: DGCollectionViewPaginableBehaviorDelegate
extension ItemsCollectionViewController: DGCollectionViewPaginableBehaviorDelegate {
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
        let size = CGSize(width: width.floor, height: height.floor)
        return size
    }

    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, countPerPageInSection section: Int) -> Int {
        return model.countPerPage()
    }

    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, fetchDataFrom indexPath: IndexPath, count: Int, completion: @escaping (Error?, Int) -> Void) {
        if searchControllerNew.isActive {
            guard searchControllerNew.searchBar.text!.count > 2 else {
                completion(nil, 0)
                return
            }
            model.loadSearchItems(searchControllerNew.searchBar.text!, iOS11: true, { [weak self] (resultCount) in
                guard let strongSelf = self else { return }
                if strongSelf.model.pageOfSearch > strongSelf.model.totalPagesOfSearch {
                    completion(nil, 0)
                } else {
                    completion(nil, resultCount ?? 0)
                }
            })
        } else {
            model.loadVideoItems { [weak self] (resultCount) in
                guard let strongSelf = self else { return }
                if strongSelf.model.page > strongSelf.model.totalPages {
                    completion(nil, 0)
                } else {
                    completion(nil, resultCount ?? 0)
                }
            }
        }
    }
    
    func paginableBehavior(_ paginableBehavior: DGCollectionViewPaginableBehavior, didAutoFetchDataFor section: Int) {
        reloadEmptyStateForCollectionView(collectionView!)
    }
}

// MARK: -UIEmptyStateDelegate, UIEmptyStateDataSource
extension ItemsCollectionViewController: UIEmptyStateDelegate, UIEmptyStateDataSource {
    // MARK: - Empty State Data Source
    var emptyStateImage: UIImage? {
        return UIImage(named: "Movies")?.filled(withColor: UIColor.kpGreyishTwo)
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite,
                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
        return NSAttributedString(string: "Нет результатов.", attributes: attrs)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont.init(name: "UniSansSemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12)]
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
        Helper.hapticGenerate(style: .medium)
        refresh()
    }
}

// MARK: AZSearchView DataSource
extension ItemsCollectionViewController: AZSearchViewDataSource {
    func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    func results() -> [AnyObject] {
        return model.resultItems
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.reuseIdentifier) as! SearchResultTableViewCell
        cell.configure(with: model.resultItems[indexPath.row])
        return cell
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: AZSearchView Delegate
extension ItemsCollectionViewController: AZSearchViewDelegate {
    func searchView(_ searchView: AZSearchViewController, didSearchForText text: String) {
        searchView.searchBar.endEditing(true)
    }

    func searchView(_ searchView: AZSearchViewController, didTextChangeTo text: String, textLength: Int) {
        model.resultItems.removeAll()
        if textLength > 2 {
            searchController.emptyResultCellText = "загрузка..."
            model.loadSearchItems(text, { [weak self] _ in
                self?.searchController.emptyResultCellText = "Нет результатов поиска"
                searchView.reloadData()
            })
        }
        searchView.reloadData()
    }

    func searchView(_ searchView: UITableView, didSelectResultAt indexPath: IndexPath, object: AnyObject) {
        if let cell = searchView.cellForRow(at: indexPath) as? SearchResultTableViewCell {
            if let image = cell.posterImageView.image {
                self.searchController.dismiss(animated: true, completion: { [weak self] in
                    self?.showDetailVC(with: object as! Item, andImage: image)
                })
            }
        }
    }

    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
}

// MARK: UISearchResultsUpdating
extension ItemsCollectionViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView?.reloadData()
        guard searchController.searchBar.text!.count > 2 else { return }
        model.refreshSearch()
//        model.resultItems.removeAll()
//        model.loadSearchItems(searchController.searchBar.text! ) { [weak self] _ in
//            guard let strongSelf = self else { return }
//            strongSelf.collectionView?.reloadData()
//        }
        behavior.reloadData()
        behavior.fetchNextData(forSection: 0) { [weak self] in
            self?.endLoad()
        }
//        collectionView?.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        model.resultItems.removeAll()
        behavior.reloadData()
        endLoad()
//        searchController.dismiss(animated: true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchController.show(in: self)
    }
    
    
}

// MARK: AccountManager Delegate
extension ItemsCollectionViewController: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        refresh()
    }
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {
        refresh()
    }
}

// MARK: VideoItemsModel Delegate
extension ItemsCollectionViewController: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        // Forces deinit cells.
        endLoad()
    }
}

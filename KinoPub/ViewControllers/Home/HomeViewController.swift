//
//  HomeViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 12.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import UIKit
import InteractiveSideMenu
import AZSearchView
import GradientLoadingBar
import UIEmptyState

class HomeViewController: UIViewController, SideMenuItemContent {
    
    private let model = Container.ViewModel.videoItems()
    fileprivate let accountManager = Container.Manager.account
    
    var searchController: AZSearchViewController!
    var searchTimer: Timer?
    let control = UIRefreshControl()
    var storedOffsets = [Int: CGFloat]()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()
        initData()
        delegates()
        configView()
        configTableView()
        configPullToRefresh()
        configSearch()
        configEmptyTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delegates() {
        accountManager.addDelegate(delegate: self)
        model.delegate = self
    }
    
    func configView() {
        title = "Главная"
        view.backgroundColor = .kpBackground
        view.tintColor = .kpGreyishTwo
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedString.Key.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
    }
    
    func configTableView() {
        tableView.backgroundColor = .clear
        tableView.tintColor = .kpOffWhite
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: String(describing: ItemsTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: String(describing: ItemsTableViewCell.self))
    }
    
    func configPullToRefresh() {
        control.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        control.tintColor = .kpOffWhite
        if #available(iOS 10.0, *) {
            tableView?.refreshControl = control
        } else {
            tableView?.addSubview(control)
        }
    }
    
    func configSearch() {
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
        searchController.tableViewBackgroundColor = .kpBackground
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeSearchBar(_:)))
        item.tintColor = .kpMarigold
        searchController.navigationItem.rightBarButtonItem = item
    }
    
    func configEmptyTable() {
        emptyStateDataSource = self
        emptyStateDelegate = self
    }
    
    func initData() {
        model.loadNewFilms()
        model.loadNewSeries()
        model.loadHotFilms()
        model.loadHotSeries()
        model.loadFreshMovies()
        model.loadFreshSeries()
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        tableView.reloadData()
        reloadEmptyStateForTableView(tableView)
        control.endRefreshing()
        GradientLoadingBar.shared.hide()
    }
    
    @objc func refresh() {
        beginLoad()
        initData()
    }

    // MARK: - Navigation
    
    @IBAction func showMenu(_ sender: Any) {
        if let navigationViewController = self.navigationController as? SideMenuItemContent {
            navigationViewController.showSideMenu()
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchController.show(in: self)
    }
    
    @objc func showItems(_ sender: KPGestureRecognizer) {
        if let itemsVC = ItemsCollectionViewController.storyboardInstance() {
            itemsVC.itemsTag = sender.tag?.rawValue
            navigationController?.pushViewController(itemsVC, animated: true)
        }
    }
    
    @objc func tap(sender: KPGestureRecognizer) {
        guard sender.item != nil else { return }
        if let indexPath = sender.collectionView?.indexPathForItem(at: sender.location(in: sender.collectionView)) {
            if let cell = sender.collectionView?.cellForItem(at: indexPath) as? ItemCollectionViewCell {
                if let image = cell.posterImageView.image {
                    showDetailVC(with: sender.item!, andImage: image)
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
    
    @objc func closeSearchBar(_ sender: AnyObject?) {
        searchController.dismiss(animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return model.newFilms.count > 0 ? 1 : 0
        case 1:
            return model.newSeries.count > 0 ? 1 : 0
        case 2:
            return model.freshMovies.count > 0 ? 1 : 0
        case 3:
            return model.freshSeries.count > 0 ? 1 : 0
        case 4:
            return model.hotFilms.count > 0 ? 1 : 0
        case 5:
            return model.hotSeries.count > 0 ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemsTableViewCell.self), for: indexPath) as! ItemsTableViewCell
        cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ItemsTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
        let tap = KPGestureRecognizer(target: self, action: #selector(showItems(_:)))
        tableViewCell.addGestureRecognizer(tap)
        switch indexPath.section {
        case 0:
            tap.tag = TabBarItemTag.newMovies
            tableViewCell.titleLabel.text = "Новые фильмы"
        case 1:
            tap.tag = TabBarItemTag.newSeries
            tableViewCell.titleLabel.text = "Новые сериалы"
        case 2:
            tap.tag = TabBarItemTag.freshMovies
            tableViewCell.titleLabel.text = "Свежие фильмы"
        case 3:
            tap.tag = TabBarItemTag.freshSeries
            tableViewCell.titleLabel.text = "Свежие сериалы"
        case 4:
            tap.tag = TabBarItemTag.hotMovies
            tableViewCell.titleLabel.text = "Популярные фильмы"
        case 5:
            tap.tag = TabBarItemTag.hotSeries
            tableViewCell.titleLabel.text = "Популярные сериалы"
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? ItemsTableViewCell else { return }
        storedOffsets[indexPath.section] = tableViewCell.collectionViewOffset
    }
    
}

extension HomeViewController: UIEmptyStateDelegate, UIEmptyStateDataSource {
    // MARK: - Empty State Data Source
    var emptyStateImage: UIImage? {
        return UIImage(named: "Movies")
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.kpOffWhite,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
        return NSAttributedString(string: "Нет результатов.\nВозможно, отсутствует интернет соединение или сервис временно недоступен.", attributes: attrs)
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 0:
            return model.newFilms.count
        case 1:
            return model.newSeries.count
        case 2:
            return model.freshMovies.count
        case 3:
            return model.freshSeries.count
        case 4:
            return model.hotFilms.count
        case 5:
            return model.hotSeries.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemCollectionViewCell.self), for: indexPath) as! ItemCollectionViewCell
        let gesture = KPGestureRecognizer(target: self, action: #selector(tap))
        cell.addGestureRecognizer(gesture)
        gesture.collectionView = collectionView
        switch collectionView.tag {
        case 0:
            cell.set(item: model.newFilms[indexPath.row])
            gesture.item = model.newFilms[indexPath.row]
        case 1:
            cell.set(item: model.newSeries[indexPath.row])
            gesture.item = model.newSeries[indexPath.row]
        case 2:
            cell.set(item: model.freshMovies[indexPath.row])
            gesture.item = model.freshMovies[indexPath.row]
        case 3:
            cell.set(item: model.freshSeries[indexPath.row])
            gesture.item = model.freshSeries[indexPath.row]
        case 4:
            cell.set(item: model.hotFilms[indexPath.row])
            gesture.item = model.hotFilms[indexPath.row]
        case 5:
            cell.set(item: model.hotSeries[indexPath.row])
            gesture.item = model.hotSeries[indexPath.row]
        default:
            break
        }
        return cell
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.height
        let cellWidth = cellHeight / 1.569
        return  CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: AZSearchView DataSource
extension HomeViewController: AZSearchViewDataSource {
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
extension HomeViewController: AZSearchViewDelegate {
    func searchView(_ searchView: AZSearchViewController, didSearchForText text: String) {
        searchView.searchBar.endEditing(true)
    }
    
    func searchView(_ searchView: AZSearchViewController, didTextChangeTo text: String, textLength: Int) {
        model.resultItems.removeAll()
        searchController.emptyResultCellText = "загрузка..."
        if let timer = searchTimer {
            timer.invalidate()
            searchTimer = nil
        }
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: false)
        searchView.reloadData()
    }
    
    @objc func timerFired(_ timer: Timer?) {
        searchTimer?.invalidate()
        searchTimer = nil
        guard let text = searchController.searchBar.text, text.count > 2 else { return }
        model.loadSearchItems(text, { [weak self] _ in
            self?.searchController.emptyResultCellText = "Нет результатов поиска"
            self?.searchController.reloadData()
        })
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

// MARK: AccountManager Delegate
extension HomeViewController: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        refresh()
    }
}

// MARK: VideoItemsModel Delegate
extension HomeViewController: VideoItemsModelDelegate {
    func didUpdateItems(model: VideoItemsModel) {
        endLoad()
    }
}


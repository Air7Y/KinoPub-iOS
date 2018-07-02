//
//  FilterViewController.swift
//  KinoPub
//
//  Created by Евгений Дац on 08.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
import Eureka
import GradientLoadingBar

class FilterViewController: FormViewController {
    let model = Container.ViewModel.filter()
    var year: Int {
        let date = Date()
        let calendar = Calendar.current
        return calendar.component(.year, from: date)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        beginLoad()

        model.delegate = self
        
        config()
        configTable()
        configForm()
        
        model.loadItemsGenres()
        model.loadItemsCountry()
        model.loadItemsSubtitles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    @IBAction func applyButtonTap(_ sender: UIBarButtonItem) {
        goBack(sender)
    }
    
    class func storyboardInstance() -> FilterViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as? FilterViewController
    }
    
    func beginLoad() {
        GradientLoadingBar.shared.show()
    }
    
    func endLoad() {
        tableView.reloadData()
        GradientLoadingBar.shared.hide()
    }
    
    func config() {
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationItem.largeTitleDisplayMode = .always
            let attributes = [NSAttributedStringKey.foregroundColor : UIColor.kpOffWhite]
            navigationController?.navigationBar.largeTitleTextAttributes = attributes
        }
        
        tableView.backgroundColor = .kpBackground
        view.backgroundColor = .kpBackground
        navigationItem.rightBarButtonItem?.tintColor = .kpMarigold
        
        if #available(iOS 11.0, *) {
            
        } else {
            var offset: CGFloat = 44
            if let navBarHeight = navigationController?.navigationBar.frame.height {
                offset = navBarHeight
            }
            tableView.contentInset = UIEdgeInsetsMake(offset, 0, 0, 0)
        }
    }
    
    func configForm() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
        }
        
        CheckRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
        }
        
        SwitchRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.switchControl.onTintColor = .kpMarigold
            cell.switchControl.tintColor = .kpGreyishBrown
        }
        
        MultipleSelectorRow<Genres>.defaultCellUpdate = { cell, row in
            cell.tintColor = .kpGreyishBrown
            cell.setDisclosure(toColor: .kpGreyishBrown)
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            if row.value == nil || row.value!.count == 0 {
                cell.detailTextLabel!.text = row.noValueDisplayText
            }
            let _ = row.onPresent({ (_, to) in
                let _ = to.view
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                backgroundView.backgroundColor = .kpBackground
                to.tableView?.backgroundView = backgroundView
                to.tableView.separatorColor = .kpOffWhiteSeparator
                to.tableView.tintColor = .kpMarigold
                to.form.last?.header = nil
                to.selectableRowCellUpdate = { cell, row in
                    cell.tintColor = .kpMarigold
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = .kpOffWhite
                }
            })
        }
        
        MultipleSelectorRow<Countries>.defaultCellUpdate = { cell, row in
            cell.tintColor = .kpGreyishBrown
            cell.setDisclosure(toColor: .kpGreyishBrown)
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            if row.value == nil || row.value!.count == 0 {
                cell.detailTextLabel!.text = row.noValueDisplayText
            }
            let _ = row.onPresent({ (_, to) in
                let _ = to.view
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                backgroundView.backgroundColor = .kpBackground
                to.tableView?.backgroundView = backgroundView
                to.tableView.separatorColor = .kpOffWhiteSeparator
                to.tableView.tintColor = .kpMarigold
                to.form.last?.header = nil
                to.selectableRowCellUpdate = { cell, row in
                    cell.tintColor = .kpMarigold
                    cell.backgroundColor = .clear
                    cell.textLabel?.textColor = .kpOffWhite
                }
            })
        }
        
        PickerInlineRowCustom<String>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            cell.tintColor = .kpMarigold
        }
        PickerInlineRowCustom<String>.InlineRow.defaultCellUpdate = { cell, row in
            cell.pickerTextColor = .kpOffWhite
        }
        
        PickerInlineRowCustom<SerialStatus>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            cell.tintColor = .kpMarigold
        }
        PickerInlineRowCustom<SerialStatus>.InlineRow.defaultCellUpdate = { cell, row in
            cell.pickerTextColor = .kpOffWhite
        }

        PickerInlineRowCustom<SortOption>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            cell.tintColor = .kpMarigold
        }
        PickerInlineRowCustom<SortOption>.InlineRow.defaultCellUpdate = { cell, row in
            cell.pickerTextColor = .kpOffWhite
        }

        PickerInlineRowCustom<SubtitlesList>.defaultCellUpdate = { cell, row in
            cell.textLabel?.textColor = .kpOffWhite
            cell.detailTextLabel?.textColor = .kpGreyishTwo
            cell.tintColor = .kpMarigold
        }
        PickerInlineRowCustom<SubtitlesList>.InlineRow.defaultCellUpdate = { cell, row in
            cell.pickerTextColor = .kpOffWhite
        }
        
        form +++ Section()
            <<< MultipleSelectorRow<Genres>() {
                $0.title = "Жанр"
                $0.selectorTitle = "Жанр"
                $0.value = model.filter.genres
                $0.noValueDisplayText = "Не важно"
                $0.optionsProvider = .lazy({ [weak self] (form, completion) in
                    completion(self?.model.genres)
                })
                }.onChange({ [weak self] (row) in
//                    if let value = row.value, value.contains(Genres(id: 25, title: "Аниме")) {
//                        row.value = nil
//                    }
                    self?.model.filter.genres = row.value
                })
            
            <<< MultipleSelectorRow<Countries>() {
                $0.title = "Страна"
                $0.selectorTitle = "Страна"
                $0.value = model.filter.countries
                $0.noValueDisplayText = "Не важно"
                $0.optionsProvider = .lazy({ [weak self] (form, completion) in
                    completion(self?.model.countries)
                })
                }.onChange({ [weak self] (row) in
                    self?.model.filter.countries = row.value
                })
            
            <<< PickerInlineRowCustom<String>("Year") {
                $0.title = "Год выхода"
                $0.options = []
                $0.noValueDisplayText = "Не важно"
                for i in 1912...year {
                    $0.options.append(i.string)
                }
                $0.options.append("Период")
                $0.options.append("Начиная с")
                $0.options.append("Не важно")
                $0.options.reverse()
                $0.value = model.filter.year != nil ? model.filter.year : nil
                }.onChange({ [weak self] (row) in
                    if row.value == "Не важно" {
                        row.value = nil
                        self?.model.filter.yearsDict = nil
                    }
                    self?.model.filter.year = row.value
                })
        
            <<< PickerInlineRowCustom<String>("YearFrom") {
                $0.hidden = .function(["Year"], { form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "Year")
                    return (row.value == "Период" || row.value == "Начиная с") ? false : true
                })
                $0.title = "  Начало периода"
                $0.options = []
                $0.noValueDisplayText = "Не важно"
                for i in 1912...year {
                    $0.options.append(i.string)
                }
                $0.options.append("Не важно")
                $0.options.reverse()
                $0.value = model.filter.yearsDict != nil ? model.filter.yearsDict!["from"] : nil
                }
                .onChange({ [weak self] (row) in
                    if row.value == "Не важно" {
                        row.value = nil
                    }
                    if self?.model.filter.yearsDict == nil {
                        self?.model.filter.yearsDict = [String : String]()
                    }
                    self?.model.filter.yearsDict!["from"] = row.value
                })
            
            <<< PickerInlineRowCustom<String>("YearTo") {
                $0.hidden = .function(["Year"], { [weak self] form -> Bool in
                    let row: RowOf<String>! = form.rowBy(tag: "Year")
                    if row.value == "Начиная с" {
                        if self?.model.filter.yearsDict == nil {
                            self?.model.filter.yearsDict = [String : String]()
                        }
                        self?.model.filter.yearsDict!["to"] = self?.year.string
                    }
                    return row.value == "Период" ? false : true
                    })
                $0.title = "  Конец периода"
                $0.options = []
                $0.noValueDisplayText = "Не важно"
                for i in 1912...year {
                    $0.options.append(i.string)
                }
                $0.options.append("Не важно")
                $0.options.reverse()
                $0.value = model.filter.yearsDict != nil ? model.filter.yearsDict!["to"] : nil
                }
                .onChange({ [weak self] (row) in
                    if row.value == "Не важно" {
                        row.value = nil
                    }
                    if self?.model.filter.yearsDict == nil {
                        self?.model.filter.yearsDict = [String : String]()
                    }
                    self?.model.filter.yearsDict!["to"] = row.value
                })
            
            <<< PickerInlineRowCustom<SubtitlesList>("subs"){
                $0.title = "Субтитры"
                $0.noValueDisplayText = "Не важно"
                $0.options = model.subtitles
                $0.value = model.filter.subtitles
                }
                .onChange({ [weak self] (row) in
                    if row.value?.title == "Не важно" {
                        row.value = nil
                    }
                    self?.model.filter.subtitles = row.value
                })
                .cellUpdate({ [weak self] (cell, row) in
                    guard let strongSelf = self else { return }
                    row.options = strongSelf.model.subtitles
                })
            
            <<< PickerInlineRowCustom<String>("kinopiskRating"){
                $0.title = "Рейтинг КиноПоиска"
                $0.noValueDisplayText = "Не важно"
                for i in 1...9 {
                    $0.options.append("\(i) и выше")
                }
                $0.options.append("Не важно")
                $0.options.reverse()
                $0.value = model.filter.kinopoiskRating?[">="]
                }
                .onChange({ [weak self] (row) in
                    if row.value == "Не важно" {
                        row.value = nil
                    }
                    if self?.model.filter.kinopoiskRating == nil {
                        self?.model.filter.kinopoiskRating = [String : String]()
                    }
                    self?.model.filter.kinopoiskRating![">="] = row.value
                })
            
            <<< PickerInlineRowCustom<String>("imdbRating"){
                $0.title = "Рейтинг IMDb"
                $0.noValueDisplayText = "Не важно"
                for i in 1...9 {
                    $0.options.append("\(i) и выше")
                }
                $0.options.append("Не важно")
                $0.options.reverse()
                $0.value = model.filter.imdbRating?[">="]
                }
                .onChange({ [weak self] (row) in
                    if row.value == "Не важно" {
                        row.value = nil
                    }
                    if self?.model.filter.imdbRating == nil {
                        self?.model.filter.imdbRating = [String : String]()
                    }
                    self?.model.filter.imdbRating![">="] = row.value
                })
            
            <<< PickerInlineRowCustom<SerialStatus>("serialStatus"){
                $0.title = "Сортировка по статусу"
                $0.hidden = Condition.function([""], { [weak self] (_) -> Bool in
                    guard let strongSelf = self else { return true }
                    return !(strongSelf.model.type == .shows
                        || strongSelf.model.type == .tvshows
                        || strongSelf.model.type == .docuserial)
                })
                $0.options = SerialStatus.all
                $0.value = model.filter.serialStatus
                }
                .onChange({ [weak self] (row) in
                    self?.model.filter.serialStatus = row.value!
                })
            
            <<< PickerInlineRowCustom<SortOption>("sort"){
                $0.title = "Сортировка"
                $0.options = SortOption.all
                if model.type == ItemType.movies || model.type == ItemType.documovie {
                    $0.options.remove(at: $0.options.count - 1)
                }
                $0.value = model.filter.sort
                }
                .onChange({ [weak self] (row) in
                    self?.model.filter.sort = row.value!
                })
            
            <<< SwitchRow() {
                $0.title = "Сортировка по возрастанию"
                $0.value = model.filter.sortAsc
                }
                .onChange({ [weak self] (row) in
                    self?.model.filter.sortAsc = row.value!
                })
        
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "Сбросить все фильтры"
                }.onCellSelection({ [weak self] (cell, row) in
                    self?.resetFilter(row)
                }).cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .kpGreyishTwo
                    cell.textLabel?.borderWidth = 1
                    cell.textLabel?.borderColor = .kpGreyishBrown
                    cell.textLabel?.cornerRadius = 6
                })
    }
    
    func configTable() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func resetFilter(_ sender: Any) {
        model.filter = Filter.defaultFilter
        goBack(sender)
    }
    
    @objc func goBack(_ sender: Any) {
        for vc in (self.navigationController?.viewControllers)! {
            if let ivc = vc as? ItemsCollectionViewController {
                ivc.model.filter = model.filter
                ivc.filterBack()
                navigationController?.popToViewController(ivc, animated: true)
            }
        }
    }
    
    @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

}

extension FilterViewController: FilterModelDelegate {
    func didUpdateItems(model: FilterModel) {
        endLoad()
    }
}

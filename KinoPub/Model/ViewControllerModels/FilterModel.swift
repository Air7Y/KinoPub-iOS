//
//  FilterModel.swift
//  KinoPub
//
//  Created by Евгений Дац on 07.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import NotificationBannerSwift

protocol FilterModelDelegate: class {
    func didUpdateItems(model: FilterModel)
}
class FilterModel {
    weak var delegate: FilterModelDelegate?
    var type: ItemType?
    var genres = [Genres]()
    var countries = [Countries]()
    var subtitles = [SubtitlesList]()
    var filter = Filter.defaultFilter {
        didSet {
            print(filter)
        }
    }
    
    let accountManager: AccountManager
    let networkingService: FilterNetworkingService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = FilterNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func loadItemsGenres() {
        networkingService.receiveItemsGenres(type: type?.rawValue ?? "") { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateItems(model: strongSelf) }
            if var responseData = response {
                if Config.shared.animeIsHidden {
                    responseData = responseData.filter{$0.id != 25}
                }
                strongSelf.genres.append(contentsOf: responseData)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "Unknown")
            }
        }
    }
    
    func loadItemsCountry() {
        networkingService.receiveItemsCountry { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateItems(model: strongSelf) }
            if let responseData = response {
                strongSelf.countries = responseData
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "Unknown")
            }
        }
    }
    
    func loadItemsSubtitles() {
        networkingService.receiveSubtitleItems { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateItems(model: strongSelf) }
            if let responseData = response {
                strongSelf.subtitles.append(SubtitlesList(id: "0", title: "Не важно"))
                strongSelf.subtitles.append(contentsOf: responseData)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "Unknown")
            }
        }
    }
}

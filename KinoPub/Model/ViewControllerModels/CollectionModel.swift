//
//  CollectionModel.swift
//  KinoPub
//
//  Created by Евгений Дац on 06.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import LKAlertController
import NotificationBannerSwift

protocol CollectionModelDelegate: class {
    func didUpdateItem(model: CollectionModel)
}

class CollectionModel {
    weak var delegate: CollectionModelDelegate?
    var collections = [Collections]()
    var page: Int = 1
    
    let accountManager: AccountManager
    let networkingService: CollectionsNetworkingService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = CollectionsNetworkingService(requestFactory: accountManager.requestFactory)
        //        accountManager.addDelegate(delegate: self)
    }
    
    func loadCollections(completed: @escaping (_ count: Int?) -> ()) {
        networkingService.receiveCollections(page: page.string) { [weak self] (response, error) in
        guard let strongSelf = self else { return }
            var count: Int?
            defer { completed(count) }
            if let itemsData = response {
                guard let items = itemsData.items else { return }
                strongSelf.page += 1
                strongSelf.collections.append(contentsOf: items)
                count = items.count
            } else {
                Helper.showError(error?.localizedDescription ?? "Unknown")
            }
        }
    }
    
    func refresh() {
        page = 1
        collections.removeAll()
    }
}

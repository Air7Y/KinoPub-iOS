//
//  TVModel.swift
//  KinoPub
//
//  Created by Евгений Дац on 12.02.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation
import NotificationBannerSwift

protocol TVModelDelegate: class {
    func didUpdateChannels(model: TVModel)
}

class TVModel {
    var sportChannels = [Channels]()
    
    let accountManager: AccountManager
    let networkingService: TVNetworkingService
    weak var delegate: TVModelDelegate?
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = TVNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func loadSportChannels() {
        guard accountManager.hasAccount else { return }
        networkingService.receiveTVChanels { [weak self] (response, error) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateChannels(model: strongSelf) }
            if let responseData = response {
                strongSelf.sportChannels = responseData
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "Unknown")
            }
        }
    }
}

//
//  LogViewsManager.swift
//  KinoPub
//
//  Created by Евгений Дац on 13.10.2017.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import LKAlertController


protocol LogViewsManager: class {
    func addDelegate(delegate: LogViewsManagerDelegate)
    func changeWatchingStatus(id: Int, video: Int?, season: Int, status: Int?)
    func changeMarktime(id: Int, time: TimeInterval, video: Int, season: Int?)
    func changeWatchlist(id: String)
    func changeWatchlistForMovie(id: Int, time: TimeInterval)
}

protocol LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager)
    func didToggledWatchlist(toggled: Bool)
}

extension LogViewsManagerDelegate {
    func didChangeStatus(manager: LogViewsManager) {}
    func didToggledWatchlist(toggled: Bool) {}
}

class LogViewsManagerImp: LogViewsManager {
    let accountManager = Container.Manager.account
    var delegatesStorage = DelegatesStorage()
    let networkingService: LogViewsNetworkingService
    
    
    init() {
        networkingService = LogViewsNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func addDelegate(delegate: LogViewsManagerDelegate) {
        delegatesStorage.addDelegate(delegate: delegate as AnyObject)
    }
    
    func changeWatchingStatus(id: Int, video: Int?, season: Int, status: Int?) {
        networkingService.changeWatchingStatus(id: id, video: video, season: season, status: status) {(response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
                    (delegate as! LogViewsManagerDelegate).didChangeStatus(manager: self)
                }
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? response?.status.string ?? "Unknown")
            }
        }
    }
    
    func changeMarktime(id: Int, time: TimeInterval, video: Int, season: Int?) {
        guard accountManager.hasAccount else { return }
        networkingService.changeMarktime(id: id, time: time, video: video, season: season) { (_, _) in
            
        }
    }
    
    func changeWatchlistForMovie(id: Int, time: TimeInterval) {
        networkingService.changeMarktime(id: id, time: time, video: 1, season: nil) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
                    (delegate as! LogViewsManagerDelegate).didChangeStatus(manager: self)
                }
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? response?.status.string ?? "Unknown")
            }
        }
    }
    
    func changeWatchlist(id: String) {
        networkingService.changeWatchlist(id: id) { (response, error) in
            if let responseData = response, responseData.status == 200 {
                self.delegatesStorage.enumerateDelegatesWithBlock { (delegate) in
                    (delegate as! LogViewsManagerDelegate).didToggledWatchlist(toggled: (response?.watching)!)
                }
                let str = responseData.watching! ? "добавлен в" : "удален из"
                Helper.showSuccessStatusBarBanner("Сериал \(str) \"Я смотрю\"")
            } else if response?.status == 0 {
                Helper.showErrorBanner("Невозможно добавить в Watchlist. \(error?.localizedDescription ?? response?.status.string ?? "Unknown")")
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? response?.status.string ?? "Unknown")
            }
        }
    }
}

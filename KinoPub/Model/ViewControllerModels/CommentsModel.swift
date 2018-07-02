//
//  CommentsModel.swift
//  qinoa
//
//  Created by Евгений Дац on 28.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import Foundation

protocol CommentsModelDelegate: class {
    func didUpdateComments()
}

class CommentsModel: AccountManagerDelegate {
    weak var delegate: CommentsModelDelegate?
    
    var comments = [Comments]()
    
    let accountManager: AccountManager
    let networkingService: CommentsNetworkingService
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
        networkingService = CommentsNetworkingService(requestFactory: accountManager.requestFactory)
    }
    
    func loadNoDeletedComments(for id: String) {
        loadAllComments(for: id) { [weak self] (comments) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateComments() }
            guard let comments = comments else { return }
            strongSelf.comments = comments.filter{!$0.deleted!}
        }
    }
    
    func loadTopComments(for id: String) {
        loadAllComments(for: id) { [weak self] (comments) in
            guard let strongSelf = self else { return }
            defer { strongSelf.delegate?.didUpdateComments() }
            guard let comments = comments else { return }
            strongSelf.comments = Array(comments.sorted(by: {$0.rating?.int ?? 0 > $1.rating?.int ?? 0}).prefix(3))
        }
    }
    
    private func loadAllComments(for id: String, completed: @escaping (_ comments: [Comments]?) -> ()) {
        networkingService.receiveComments(id: id) { (response, error) in
            if let data = response {
                completed(data.comments)
            } else {
                Helper.showErrorBanner(error?.localizedDescription ?? "Unknown")
                completed(nil)
            }
        }
    }
}

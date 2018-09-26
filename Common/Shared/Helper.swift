//
//  Helper.swift
//  KinoPub
//
//  Created by Евгений Дац on 20.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import UIKit
import LKAlertController
#if os(iOS)
import NotificationBannerSwift
#endif

class Helper {
    /* Description: This function generate alert dialog for empty message by passing message and
     associated viewcontroller for that function
     - Parameters:
     - message: message that require for  empty alert message
     - viewController: selected viewcontroller at that time
     */
    static func EmptyMessage(message: String, viewController: UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size.width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        
        messageLabel.textColor = .kpGreyishBrown
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
//        messageLabel.font = UIFont(name: "TrebuchetMS", size: 18)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel;
        #if os(iOS)
        viewController.tableView.separatorStyle = .none;
        #endif
    }
    
    @available(iOS 10.0, *)
    static func hapticGenerate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if os(iOS)
        let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        #endif
    }
    
    static func showError(_ message: String?) {
        let alert = Alert(title: "Ошибка", message: message ?? "Unknown")
        #if os(iOS)
        alert.tint(.kpBlack)
        #endif
        alert.addAction("Ok").show()
    }
    
    static func showErrorTrailerAlert() {
        let alert = Alert(title: "Ошибка", message: "Трейлер не найден. \n По возможности сообщите в стол заказов в Telegram.")
        #if os(iOS)
        alert.tint(.kpBlack)
        alert.addAction("Перейти в Telegram", style: .default, handler: { (_) in
            guard let telegram = URL(string: "https://t.me/kinopubrequest") else { return }
            UIApplication.shared.open(url: telegram)
        })
        #endif
        alert.addAction("Закрыть", style: .cancel)
        alert.show()
    }
    
    static func showSuccessStatusBarBanner(_ message: String) {
        #if os(iOS)
        let banner = StatusBarNotificationBanner(title: message, style: .success)
        banner.duration = 1
        banner.show(queuePosition: .front)
        #endif
    }
    
    static func showErrorBanner(_ message: String) {
        #if os(iOS)
        let banner = NotificationBanner(title: "Ошибка", subtitle: message, style: .danger)
        banner.show(queuePosition: .front)
        #endif
    }
}

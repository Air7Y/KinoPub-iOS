import UIKit
import LKAlertController
import NotificationBannerSwift

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
        viewController.tableView.separatorStyle = .none;
    }
    
    static func hapticGenerate(style: UIImpactFeedbackStyle) {
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: style)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
    }
    
    static func showError(_ message: String) {
        Alert(title: "Ошибка", message: message).tint(.kpBlack).showOkay()
    }
    
    static func showErrorTrailerAlert() {
        Alert(title: "Ошибка", message: "Трейлер не найден. \n По возможности сообщите в стол заказов в Telegram.").tint(.kpBlack)
            .addAction("Перейти в Telegram", style: .default, handler: { (_) in
                guard let telegram = URL(string: "https://t.me/kinopubrequest") else { return }
                UIApplication.shared.open(url: telegram)
            })
            .addAction("Закрыть", style: .cancel)
            .show()
    }
    
    static func showSuccessStatusBarBanner(_ message: String) {
        let banner = StatusBarNotificationBanner(title: message, style: .success)
        banner.duration = 1
        banner.show(queuePosition: .front)
    }
    
    static func showErrorBanner(_ message: String) {
        let banner = NotificationBanner(title: "Ошибка", subtitle: message, style: .danger)
        banner.show(queuePosition: .front)
    }
}

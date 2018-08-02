//
//  ErrorBackgroundView.swift
//  KinoPub
//
//  Created by Евгений Дац on 13.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

protocol ErrorBackgroundViewDelegate: class {
    func updateButtonDidTappedInErrorView(_ sender: Any)
}

class ErrorBackgroundView: UIView {
    
    weak var delegate: ErrorBackgroundViewDelegate?
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var descriptionLabel: UILabel?
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        delegate?.updateButtonDidTappedInErrorView(sender)
    }
    
    override func awakeFromNib() {
        backgroundColor = .kpBackground
        titleLabel?.textColor = .kpOffWhite
        descriptionLabel?.textColor = .kpGreyishTwo
    }
    
    func configView(title: String? = nil, description: String? = nil) {
        titleLabel?.text = title
        descriptionLabel?.text = description
    }
    
    func configView(error: NSError) {
        let helpfulDescription: String
        let title: String
        switch error.code {
        case -1200:
            title = "SSL Error".localized
            helpfulDescription = "It looks like your ISP/Network admin is blocking our servers. You can try again with a VPN to hide your internet traffic from them. Please do so at your own risk".localized
        case -404:
            title = "Not found".localized
            helpfulDescription = "Please check your internet connection and try again.".localized
        case -1005, -1009:
            title = "You're Offline".localized
            helpfulDescription = "Please make sure you have a valid internet connection and try again.".localized
        default:
            title = "Unknown Error".localized
            helpfulDescription = error.localizedDescription
        }
        configView(title: title, description: helpfulDescription)
    }

}

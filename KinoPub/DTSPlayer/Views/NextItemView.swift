//
//  NextItem.swift
//  qinoa
//
//  Created by Евгений Дац on 25.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

protocol NextItemDelegate: class {
    func didPressNextButton()
}

class NextItemView: UIView {
    
    weak var delegate: NextItemDelegate?
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func nextButtonDidTapped(_ sender: Any) {
        delegate?.didPressNextButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    func configView() {
        backgroundColor = .clear
        if #available(iOS 11.0, *) {
            nextButton.tintColor = UIColor.white
            addBlurEffect(with: .dark, orColor: UIColor.kpBlack30)
        } else {
            nextButton.tintColor = UIColor.black
            addBlurEffect(with: .light, orColor: UIColor.kpWhite30)
        }
    }
    
    func config(with info: String, image: UIImage? = nil) {
        nextButton.setTitle(info, for: .normal)
        nextButton.setImage(image, for: .normal)
        nextButton.centerTextAndImage(spacing: image != nil ? 8 : 0)
    }

}

//
//  TVButton.swift
//  qinoaTV
//
//  Created by Евгений Дац on 09/08/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import FocusTvButton

class TVButton: FocusTvButton {
    
    var normalColor: UIColor = .kpGreyishBrown
    var focusedColor: UIColor = .kpGreyishBrown
    var titleColor: UIColor = .kpGreyishTwo

    override func awakeFromNib() {
        configView()
    }
    
    func configView() {
        normalBackgroundColor = normalColor
        focusedBackgroundColor = focusedColor
        normalTitleColor = titleColor
        focusedTitleColor = titleColor
        tintColor = titleColor
        setValue(12.0, forKey: "cornerRadius")
    }

}

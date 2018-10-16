//
//  TitleVIew.swift
//  qinoa
//
//  Created by Евгений Дац on 26.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class TitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    func configView() {
        backgroundColor = .clear
        titleLabel.textColor = UIColor.white
        addBlurEffect(with: .dark, orColor: UIColor.kpBlack30)
    }
    
    func config(with title: String) {
        titleLabel.text = title
    }

}

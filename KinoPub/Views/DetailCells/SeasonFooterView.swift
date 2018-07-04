//
//  SeasonFooterView.swift
//  qinoa
//
//  Created by Евгений Дац on 04.07.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class SeasonFooterView: UICollectionReusableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .kpBlackTwo
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.roundCorners([.topRight, .bottomRight], radius: 6)
    }
    
}

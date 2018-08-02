//
//  MenuItemCollectionViewCell.swift
//  qinoaTV
//
//  Created by Евгений Дац on 26/07/2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class MenuItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configView()
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        guard let item = context.nextFocusedItem, item is MenuItemCollectionViewCell else { return }
        coordinator.addCoordinatedAnimations({
            self.focusDidChange()
        })
    }
    
    func configView() {
        backgroundColor = .clear
        label.textColor = .kpGreyish
        label.highlightedTextColor = .kpMarigold
        imageView.tintColor = .kpGreyishBrown
    }
    
    private func focusDidChange() {
        imageView.tintColor = isFocused ? .kpMarigold : .kpGreyishBrown
        label.textColor = isFocused ? .kpMarigold : .kpGreyish
    }
}

extension MenuItemCollectionViewCell: CellCustomizing {
    func configureCell<T>(with item: T) {
        guard let item = item as? MenuItems else { fatalError(">>> initializing cell with invalid item") }
        isHidden = false
        imageView.image = UIImage(named: item.icon) ?? UIImage(named: "first")
        label.text = item.name
    }
}

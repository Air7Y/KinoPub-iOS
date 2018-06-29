//
//  AllCommentsTableViewCell.swift
//  qinoa
//
//  Created by Евгений Дац on 29.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit

class AllCommentsTableViewCell: UITableViewCell {
    private var id: String!
    
    @IBOutlet weak var viewAllCommentsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }
    
    func configView() {
        backgroundColor = .clear
        viewAllCommentsLabel.text = "Посмотреть все комментарии"
        viewAllCommentsLabel.font = UIFont.linkRegular
        viewAllCommentsLabel.textColor = UIColor.kpTangerine
        viewAllCommentsLabel.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewAllComments))
        viewAllCommentsLabel.addGestureRecognizer(tap)
    }
    
    func set(id: Int?) {
        guard let id = id else {
            viewAllCommentsLabel.removeGestureRecognizers()
            return
        }
        self.id = id.string
    }
    
    @objc func viewAllComments() {
        if let commentsVC = CommentsVC.storyboardInstance() {
            commentsVC.id = id
            parentViewController?.navigationController?.show(commentsVC, sender: self)
        }
    }
    
}

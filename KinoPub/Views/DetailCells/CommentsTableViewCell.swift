//
//  CommentsTableViewCell.swift
//  qinoa
//
//  Created by Евгений Дац on 28.06.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import AlamofireImage
import Atributika

class CommentsTableViewCell: UITableViewCell {
    var isDepth = true
    var isHiddenSpoiler = true
    var atrStyles = [Style]()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }

    func configView() {
        backgroundColor = .clear
        
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.kpGreyishBrown
        
        usernameLabel.textColor = UIColor.kpOffWhite
        ratingLabel.textColor = UIColor.kpTangerine
        dateLabel.textColor = UIColor.kpGreyishBrown
        commentLabel.textColor = UIColor.kpGreyishTwo
        
        usernameLabel.font = UIFont.textRegular
        commentLabel.font = UIFont.textRegular
        
        dateLabel.isHidden = true
        
        for i in 1...9 {
            let view = getCircleView(i)
            self.addSubview(view)
            view.center.y = avatarImageView.center.y
            view.x = CGFloat(15 + (i - 1) * 10)
            view.isHidden = true
        }
        
        let spoilerStyle = Style("spoiler").font(.systemFont(ofSize: 15)).foregroundColor(.kpTangerine)
        atrStyles = [spoilerStyle]
    }
    
    func config(with comment: Comments) {
        if let imageUrl = comment.user?.avatar {
            avatarImageView.af_setImage(withURL: URL(string: imageUrl + "?s=200&d=https://cdn.service-kp.com/icon/anon_m.png")!,
                                        placeholderImage: UIImage(named: "anon_m"))
        } else {
            avatarImageView.image = UIImage(named: "anon_m")
        }
        
        usernameLabel.text = comment.user?.name
        ratingLabel.text = comment.rating
        
        var message = comment.message ?? ""
        if isHiddenSpoiler {
            let regex = try! NSRegularExpression(pattern: "(<spoiler>)(.*?)(</spoiler*>)", options: [.caseInsensitive, .dotMatchesLineSeparators])
            let range = NSMakeRange(0, message.count)
            message = regex.stringByReplacingMatches(in: message, options: [], range: range, withTemplate: "$1spoiler$3")
        }
        commentLabel.attributedText = message.style(tags: atrStyles).attributedString
        
        let format = DateFormatter()
        format.dateFormat = "@ dd.MM.yyyy в hh:mm"
        if let created = comment.created {
            dateLabel.text = format.string(from: Date(timeIntervalSince1970: created.double))
            dateLabel.isHidden = false
        } else {
            dateLabel.isHidden = true
        }
        
        guard isDepth else { return }
        if let depth = comment.depth, depth > 0 {
            avatarLeadingConstraint.constant = CGFloat(15 + depth * 10)
            for i in 1...depth {
                self.viewWithTag(i)?.isHidden = false
            }
            for i in depth + 1...9 {
                self.viewWithTag(i)?.isHidden = true
            }
        } else {
            avatarLeadingConstraint.constant = 15
            for i in 1...9 {
                self.viewWithTag(i)?.isHidden = true
            }
        }
    }
    
    func disableDepth() {
        isDepth = false
    }
    
    func getCircleView(_ tag: Int) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 4, height: 4))
        view.tag = tag
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.width / 2
        view.backgroundColor = UIColor.kpGreyishBrown
        return view
    }
    
}

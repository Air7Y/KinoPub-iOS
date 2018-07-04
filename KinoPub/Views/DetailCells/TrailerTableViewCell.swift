//
//  TrailerTableViewCell.swift
//  KinoPub
//
//  Created by Евгений Дац on 05.01.2018.
//  Copyright © 2018 Evgeny Dats. All rights reserved.
//

import UIKit
import CustomLoader

class TrailerTableViewCell: UITableViewCell {
    
    var youtubeID: String?
    
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var playButtonView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        configView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configView() {
        backgroundColor = .clear
        thumbView.dropShadow(color: .black, opacity: 0.3, offSet: CGSize(width: 0, height: 2.0), radius: 6, scale: true)
        playButtonView.backgroundColor = .kpMarigold
        playButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(play)))
    }
    
    func config(with trailer: Trailer?) {
        guard let trailer = trailer else { return }
        if let id = trailer.id {
            youtubeID = id
        } else if let link = trailer.url {
            let reversed = String(link.reversed())
            let array = reversed.components(separatedBy: "/")
            if let reversed = array.first?.reversed() {
                youtubeID = String(reversed)
            }
        }
        guard let id = youtubeID else { return }
        thumbImageView.af_setImage(withURL: URL(string: "https://img.youtube.com/vi/\(id)/maxresdefault.jpg")!,
                                   placeholderImage: UIImage(named: "episode.png"),
                                   imageTransition: .crossDissolve(0.2),
                                   runImageTransitionIfCached: false) { [weak self] (response) in
                                    if response.result.isFailure {
                                        self?.setImage(withId: id)
                                    }
        }
    }
    
    func setImage(withId id: String) {
        thumbImageView.af_setImage(withURL: URL(string: "https://img.youtube.com/vi/\(id)/0.jpg")!,
                                   placeholderImage: UIImage(named: "episode.png"),
                                   imageTransition: .crossDissolve(0.2),
                                   runImageTransitionIfCached: false)
    }
    
    @objc func play() {
        playButtonView.alpha = 0.7
        UIView.animate(withDuration: 0.8, animations: { [weak self] in
            self?.playButtonView.alpha = 1
        })
        guard let id = youtubeID else { return }
        MediaManager.shared.playYouTubeVideo(withID: id)
        Helper.hapticGenerate(style: .medium)
    }
    
}

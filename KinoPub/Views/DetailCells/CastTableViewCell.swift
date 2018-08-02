//
//  CastTableViewCell.swift
//  KinoPub
//
//  Created by hintoz on 27.04.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit

class CastTableViewCell: UITableViewCell {
    var actors = [Any]()
    var directors = [Any]()

    @IBOutlet weak var actorsTitleLabel: UILabel!
    @IBOutlet weak var directorsTitleLabel: UILabel!

    @IBOutlet weak var directorStackView: UIStackView!
    @IBOutlet weak var actorsStackView: UIStackView!
    
    @IBOutlet weak var directorCollectionView: UICollectionView! {
        didSet {
            directorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    @IBOutlet weak var actorCollectionView: UICollectionView! {
        didSet {
            actorCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }
    @IBOutlet weak var actorCellectionHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = UIColor.clear
        configureLabels()

        directorCollectionView.register(UINib(nibName: String(describing: ActorCollectionViewCell.self), bundle: Bundle.main),
                                        forCellWithReuseIdentifier: String(describing: ActorCollectionViewCell.self))
        actorCollectionView.register(UINib(nibName: String(describing: ActorCollectionViewCell.self), bundle: Bundle.main),
                                        forCellWithReuseIdentifier: String(describing: ActorCollectionViewCell.self))
        directorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapDirector(_:))))
        actorCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapActor(_:))))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with actors: String?, directors: String?) {
        configure(directors: directors)
        directorCollectionView.reloadData()
        configure(actors: actors)
        actorCollectionView.reloadData()
    }
    
    func config(with cast: [[Creators]]) {
        var directors = [Creators]()
        var actors = [Creators]()
        for creators in cast {
            directors.append(contentsOf: creators.filter{ $0.professionKey == "director" })
            actors.append(contentsOf: creators.filter{ $0.professionKey == "actor" })
        }
        configure(directors: directors)
        directorCollectionView.reloadData()
        configure(actors: actors)
        actorCollectionView.reloadData()
    }

    private func configure(actors: String?) {
        guard actors != "" else {
            actorsStackView.isHidden = true
            return
        }

        if let actors = actors?.components(separatedBy: ", ") {
            self.actors = actors
            if actors.count > 3 {
                actorCellectionHeightConstraint.constant = 170
            }
        }
    }
    
    private func configure(actors: [Creators]) {
        guard !actors.isEmpty else {
            actorsStackView.isHidden = true
            return
        }
        
        self.actors = actors
        if actors.count > 3 {
            actorCellectionHeightConstraint.constant = 170
        }
    }

    private func configure(directors: String?) {
        guard directors != "" else {
            directorStackView.isHidden = true
            return
        }

        if let directors = directors?.components(separatedBy: ", ") {
            self.directors = directors
        }
    }
    
    private func configure(directors: [Creators]) {
        guard !directors.isEmpty else {
            directorStackView.isHidden = true
            return
        }
        
        self.directors = directors
    }

    private func configureLabels() {
        actorsTitleLabel.textColor = .kpGreyishBrown
        directorsTitleLabel.textColor = .kpGreyishBrown
    }
    
    @objc private  func tapDirector(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.directorCollectionView.indexPathForItem(at: sender.location(in: self.directorCollectionView)) {
            let parameters: [String : String]
            switch directors.first {
            case is String:
                parameters = ["director" : directors[indexPath.row] as! String]
            case is Creators:
                let director = (directors[indexPath.row] as! Creators)
                let name = director.nameRU!.isEmpty ? director.nameEN : director.nameRU
                parameters = ["director" : name ?? "Oops"]
            default:
                return
            }
            showItemVC(withParameters: parameters)
        }
    }
    
    @objc private func tapActor(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.actorCollectionView.indexPathForItem(at: sender.location(in: self.actorCollectionView)) {
            let parameters: [String : String]
            switch actors.first {
            case is String:
                parameters = ["actor" : actors[indexPath.row] as! String]
            case is Creators:
                let actor = (actors[indexPath.row] as! Creators)
                let name = actor.nameRU!.isEmpty ? actor.nameEN : actor.nameRU
                parameters = ["actor" : name ?? "Oops"]
            default:
                return
            }
            showItemVC(withParameters: parameters)
        }
    }
    
    private func showItemVC(withParameters parameters: [String : String]) {
        if let itemVC = ActorCollectionViewController.storyboardInstance() {
            itemVC.viewModel.parameters = parameters
            itemVC.title = parameters["director"] ?? parameters["actor"]
            parentViewController?.navigationController?.pushViewController(itemVC, animated: true)
        }
    }
}

extension CastTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.directorCollectionView ? directors.count : actors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == directorCollectionView {
            let cell = directorCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ActorCollectionViewCell.self), for: indexPath) as! ActorCollectionViewCell
            switch directors.first {
            case is String:
                cell.config(with: directors[indexPath.row] as! String)
            case is Creators:
                cell.config(with: directors[indexPath.row] as! Creators)
            default:
                break
            }
            
            return cell
        } else {
            let cell = actorCollectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ActorCollectionViewCell.self), for: indexPath) as! ActorCollectionViewCell
            switch actors.first {
            case is String:
                cell.config(with: actors[indexPath.row] as! String)
            case is Creators:
                cell.config(with: actors[indexPath.row] as! Creators)
            default:
                break
            }
            
            return cell
        }
    }
}

extension CastTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

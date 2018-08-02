import UIKit
import AlamofireImage
import SwiftyUserDefaults
import Kingfisher
import PMKVObserver
import MarqueeLabel

protocol ItemCollectionViewCellDelegate {
    func didPressDeleteButton(_ item: Item)
    func didPressMoveButton(_ item: Item)
}

class ItemCollectionViewCell: UICollectionViewCell {
    private static let posterPlaceholderImage = R.image.posterPlaceholder()

    var item: Item!
    var delegate: ItemCollectionViewCellDelegate?
    #if os(tvOS)
        var hidesTitleLabelWhenUnfocused: Bool = false {
            didSet {
                titleLabel.alpha = hidesTitleLabelWhenUnfocused ? 0 : 1
            }
        }
    #endif

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!

    @IBOutlet weak var posterView: UIView!
//    @IBOutlet weak var enTitleLabel: UILabel!
    @IBOutlet weak var newEpisodeView: UIView!
    @IBOutlet weak var newEpisodeLabel: UILabel!
    @IBOutlet weak var kinopoiskRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var kinopubRatingLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var kinopoiskImageView: UIImageView!
    @IBOutlet weak var imdbImageView: UIImageView!
    @IBOutlet weak var kinopubImageView: UIImageView!
    
    @IBOutlet weak var editBookmarkView: UIView!
    @IBOutlet weak var deleteFromBookmarkButton: UIButton!
    @IBOutlet weak var moveFromBookmarkButton: UIButton!
    
    @IBAction func deleteFromBookmarkButtonPressed(_ sender: UIButton) {
        delegate?.didPressDeleteButton(self.item)
    }
    @IBAction func moveFromBookmarkButtonPressed(_ sender: UIButton) {
        delegate?.didPressMoveButton(self.item)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configViews()
    }
    
    func configViews() {
        titleLabel.textColor = .kpOffWhite
        
        #if os(iOS)
            posterView.dropShadow(color: UIColor.black, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
            _ = KVObserver(observer: self, object: posterView, keyPath: #keyPath(UIView.bounds), options: [.new], block: { (observer, object, _, _) in
                observer.posterView.layer.shadowPath = UIBezierPath(rect: object.bounds).cgPath
            })
        
            ratingView.addBlurEffect(with: .dark, orColor: UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.80))
        #endif
        
        // Improves performance because shadows and other effects are used.
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        #if os(tvOS)
            tintAdjustmentMode = .automatic
            //        posterImageView.adjustsImageWhenAncestorFocused = true
            hidesTitleLabelWhenUnfocused = true
            titleLabel.layer.zPosition = 10
            titleLabel.layer.shadowColor = UIColor.black.cgColor
            titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
            titleLabel.layer.shadowRadius = 2
            titleLabel.layer.shadowOpacity = 0.6
        
            focusedConstraints.append(titleLabel.widthAnchor.constraint(equalTo: posterImageView.focusedFrameGuide.widthAnchor))
            focusedConstraints.append(titleLabel.topAnchor.constraint(equalTo: posterImageView.focusedFrameGuide.bottomAnchor, constant: 3))
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        #if os(iOS)
            posterView.layer.shadowPath = UIBezierPath(rect: posterView.bounds).cgPath
        #endif
    }

    func set(item: Item) {
        configureCell(with: item)
    }
    
    private func string(rating: Int?) -> String {
        guard let rating = rating else { return "-" }
        return String(rating)
    }
    
    private func string(rating: Double?) -> String {
        guard let rating = rating else { return "-" }
        return String(format: "%.1f", rating)
    }
    
    func configure(with collection: Collections) {
        #if os(iOS)
            editBookmarkView.isHidden = true
            newEpisodeView.isHidden = true
            ratingView.isHidden = true
        #endif
        if let title = collection.title {
            titleLabel.text = title
        }

        if let poster = collection.posters?.medium, let url = URL(string: poster) {
            posterImageView.kf.setImage(with: url,
                                        placeholder: ItemCollectionViewCell.posterPlaceholderImage,
                                        options: [.backgroundDecode])
        }
    }
    
    #if os(tvOS)
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if hidesTitleLabelWhenUnfocused {
            coordinator.addCoordinatedAnimations({
                self.titleLabel.alpha = self.isFocused ? 1 : 0
            })
        }
        
        if let titleLabel = titleLabel as? MarqueeLabel {
            titleLabel.labelize = !isFocused
        }
    }
    
    #endif
}

extension ItemCollectionViewCell: CellCustomizing {
    func configureCell<T>(with item: T) {
        guard let item = item as? Item else { fatalError(">>> initializing cell with invalid item") }
        self.item = item
        
        #if os(iOS)
            editBookmarkView.isHidden = true
            newEpisodeView.isHidden = true
            ratingView.isHidden = true
        #endif
        
        if let title = item.title?.components(separatedBy: " / ") {
            titleLabel.text = title[0]
            //            enTitleLabel.text = title.count > 1 ? title[1] : ""
        }
        
        #if os(iOS)
        if let poster = item.posters?.medium, let url = URL(string: poster) {
            posterImageView.kf.setImage(with: url,
                                        placeholder: ItemCollectionViewCell.posterPlaceholderImage,
                                        options: [.backgroundDecode])
        }
        #elseif os(tvOS)
        if let poster = item.posters?.big, let url = URL(string: poster) {
            posterImageView.kf.setImage(with: url, placeholder: ItemCollectionViewCell.posterPlaceholderImage, options: [.backgroundDecode]) { [weak self] (_, _, _, _) in
                guard let strongSelf = self else { return }
                strongSelf.posterImageView.roundImage(6)
            }
        }
        #endif
        
        
        
        #if os(iOS)
            if let newEpisode = item.new {
                newEpisodeView.isHidden = false
                newEpisodeLabel.text = String(newEpisode)
            }
        
            if Defaults[.showRatringInPoster] {
                ratingView.isHidden = false
                
                kinopubRatingLabel.text = string(rating: item.rating)
                kinopoiskRatingLabel.text = string(rating: item.kinopoiskRating)
                imdbRatingLabel.text = string(rating: item.imdbRating)
            }
        #endif
    }
    
}

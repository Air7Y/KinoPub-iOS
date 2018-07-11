import UIKit
import AlamofireImage
import SwiftyUserDefaults
import Kingfisher
import PMKVObserver

protocol ItemCollectionViewCellDelegate {
    func didPressDeleteButton(_ item: Item)
    func didPressMoveButton(_ item: Item)
}

class ItemCollectionViewCell: UICollectionViewCell {

    var item: Item!
    var delegate: ItemCollectionViewCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    #if os(iOS)
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
    #endif
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configViews()
        configBlur()
    }
    
    func configViews() {
        titleLabel.textColor = .kpOffWhite
        #if os(iOS)
        posterView.dropShadow(color: UIColor.black, opacity: 0.3, offSet: CGSize(width: 0, height: 2), radius: 6, scale: true)
        _ = KVObserver(observer: self, object: posterView, keyPath: #keyPath(UIView.bounds), options: [.new], block: { (observer, object, _, _) in
            observer.posterView.layer.shadowPath = UIBezierPath(rect: object.bounds).cgPath
        })
        #endif
        // Improves performance because shadows and other effects are used.
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        #if os(tvOS)
        self.tintAdjustmentMode = .automatic
        posterImageView.adjustsImageWhenAncestorFocused = true
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        #if os(iOS)
        posterView.layer.shadowPath = UIBezierPath(rect: posterView.bounds).cgPath
        #endif
    }
    
    func configBlur() {
        #if os(iOS)
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            ratingView.backgroundColor = .clear

            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.ratingView.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            ratingView.insertSubview(blurEffectView, at: 0)
        } else {
            ratingView.backgroundColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.80)
        }
        #endif
    }

    private static let posterPlaceholderImage = R.image.posterPlaceholder()
    func set(item: Item) {
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

        if let poster = item.posters?.medium, let url = URL(string: poster) {
            posterImageView.kf.setImage(with: url,
                                        placeholder: ItemCollectionViewCell.posterPlaceholderImage,
                                        options: [.backgroundDecode])
        }
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
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [self.contentView]
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [unowned self] in
            self.posterImageView.adjustsImageWhenAncestorFocused = self.isFocused
            self.height = self.isFocused ? self.height + 70 : self.height - 70
        }, completion: nil)
    }
}

import UIKit
import Letters

class ActorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var namePersonLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        configureLabels()
    }
    
    func config<T>(with item: T) {
        if let name = item as? String {
            namePersonLabel.text = name
            personImageView.setImage(string: name, color: .kpGreyishBrown, circular: true, textAttributes: [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite])
        } else if let creator = item as? Creators {
            namePersonLabel.text = creator.nameRU!.isEmpty ? creator.nameEN : creator.nameRU
            if let posterURL = creator.posterURL,
                let url = URL(string: KPManager.shared.getFullImageUrl(for: posterURL)) {
                personImageView.cornerRadius = personImageView.height / 2
                personImageView.clipsToBounds = true
                personImageView.tintColor = .kpGreyishBrown
                personImageView.af_setImage(withURL: url,
                                            placeholderImage: UIImage(named: "Circled User Male-50"),
                                            imageTransition: .crossDissolve(0.2),
                                            runImageTransitionIfCached: false)
            } else {
                personImageView.setImage(string: namePersonLabel.text, color: .kpGreyishBrown, circular: true, textAttributes: [NSAttributedStringKey.foregroundColor: UIColor.kpOffWhite])
            }
        }
    }

    func configureLabels() {
        namePersonLabel.textColor = .kpOffWhite
    }

}

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }

    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addBlurEffect(with style: UIBlurEffectStyle, orColor color: UIColor, vibrancyView: UIView? = nil) {
        guard !UIAccessibilityIsReduceTransparencyEnabled() else {
            self.backgroundColor = color
            return
        }
        self.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(blurEffectView, at: 0)
        
        NSLayoutConstraint.activate([
            blurEffectView.heightAnchor.constraint(equalTo: self.heightAnchor),
            blurEffectView.widthAnchor.constraint(equalTo: self.widthAnchor),
            blurEffectView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            blurEffectView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        
        guard vibrancyView != nil else { return }
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyEffectView.contentView.addSubview(vibrancyView!)
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        NSLayoutConstraint.activate([
            vibrancyEffectView.heightAnchor.constraint(equalTo: blurEffectView.contentView.heightAnchor),
            vibrancyEffectView.widthAnchor.constraint(equalTo: blurEffectView.contentView.widthAnchor),
            vibrancyEffectView.centerXAnchor.constraint(equalTo: blurEffectView.contentView.centerXAnchor),
            vibrancyEffectView.centerYAnchor.constraint(equalTo: blurEffectView.contentView.centerYAnchor)
            ])
        
        NSLayoutConstraint.activate([
            vibrancyView!.centerXAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerXAnchor),
            vibrancyView!.centerYAnchor.constraint(equalTo: vibrancyEffectView.contentView.centerYAnchor),
            ])
    }
}

import UIKit
import AVKit

class DTSPlayerFullScreenViewController: AVPlayerViewController {
    
    private var nextItemView: NextItemView?
    private var titleView: TitleView?
    private var playBackControlsView: UIView? {
        return view.subviews.first?.subviews[safe: 1]?.subviews[safe: 1]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.allowsPictureInPicturePlayback = true
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playBackControlsView?.addObserver(self, forKeyPath: #keyPath(UIView.isHidden), options: .new, context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .DTSPlayerViewControllerDismissed, object: self, userInfo: nil)
    }
    
    func configNextItemView(with info: String, image: UIImage? = nil) {
        guard nextItemView == nil else {
            nextItemView?.config(with: info, image: image)
            return
        }
        nextItemView = NextItemView.fromNib()
        guard let nextItemView = nextItemView else { return }
        nextItemView.config(with: info, image: image)
        nextItemView.delegate = self
        view.addSubview(nextItemView)
        nextItemView.nextButton.layer.zPosition = 10
        
        nextItemView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            nextItemView.heightAnchor.constraint(equalToConstant: 47),
            nextItemView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    
    func configTitle(with info: String) {
        guard titleView == nil else {
            titleView?.config(with: info)
            return
        }
        titleView = TitleView.fromNib()
        guard let titleView = titleView else { return }
        titleView.config(with: info)
        contentOverlayView?.addSubview(titleView)
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleView.heightAnchor.constraint(equalToConstant: 47),
            titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
    }
    
    func removeNextButton() {
        nextItemView?.removeFromSuperview()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectView = object as? UIView,
            objectView === playBackControlsView,
            keyPath == #keyPath(UIView.isHidden) {
            nextItemView?.isHidden = objectView.isHidden
            titleView?.isHidden = objectView.isHidden
        }
    }

}

extension DTSPlayerFullScreenViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        guard let activityViewController = DTSPlayerUtils.activityViewController() else { return }
        activityViewController.present(playerViewController, animated: true) {
            completionHandler(true)
        }
    }
}

extension DTSPlayerFullScreenViewController: NextItemDelegate {
    func didPressNextButton() {
        (player as! AVQueuePlayer).advanceToNextItem()
        NotificationCenter.default.post(name: .DTSPlayerUserTappedNextButton, object: self, userInfo: nil)
    }
}

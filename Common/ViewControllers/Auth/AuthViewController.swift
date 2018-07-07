//
//  AuthViewController.swift
//  KinoPub
//
//  Created by hintoz on 16.02.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import UIKit
#if os(iOS)
import CustomLoader
#endif

class AuthViewController: UIViewController {
    fileprivate let viewModel = Container.ViewModel.auth()

    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var codeTitleLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    #if os(iOS)
    let pasteboard = UIPasteboard.general
    
    @IBOutlet weak var activateButton: UIButton!
    @IBAction func activateButtonTapped(_ sender: Any) {
        openSafariVC()
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        loadCode()
        
        #if os(iOS)
        Config.shared.delegate = self
        configButton()
        #endif
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.invalidateTimer()
    }
    
    func config() {
        errorLabel.isHidden = true
        viewModel.delegate = self
        view.backgroundColor = .kpBackground
        titleLabel.textColor = .kpOffWhite
        descLabel.textColor = .kpGreyishTwo
        codeLabel.textColor = .kpOffWhite
        codeTitleLabel.textColor = .kpGreyishBrown
        codeLabel.text = "загрузка"
    }
    
    #if os(iOS)
    func configButton() {
        activateButton.backgroundColor = .kpMarigold
        activateButton.setTitleColor(.kpBlack, for: .normal)
        activateButton.setTitle("", for: .disabled)
        activateButton.isEnabled = false
        _ = LoadingView.system(withStyle: .gray).show(inView: activateButton)
    }
    
    func updateButton() {
        activateButton.removeLoadingViews(animated: true)
        activateButton.isEnabled = true
    }
    
    func openSafariVC() {
        guard let code = viewModel.userCode else { return }
        guard let urlKpDevice = URL(string: "\(Config.shared.kinopubDomain)/device?code=\(code)") else { return }
        UIApplication.shared.open(url: urlKpDevice)
    }
    #endif
    
    func loadCode() {
        viewModel.loadDeviceCode { [weak self] (authResponse) in
            guard let strongSelf = self else { return }
            strongSelf.codeLabel.text = authResponse.userCode
            #if os(iOS)
            strongSelf.pasteboard.string = authResponse.userCode ?? ""
            strongSelf.updateButton()
            #endif
        }
    }

    static func storyboardInstance() -> AuthViewController? {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as? AuthViewController
    }

}

#if os(iOS)
extension AuthViewController: ConfigDelegate {
    func configDidLoad() {
        updateButton()
    }
}
#endif

extension AuthViewController: AuthModelDelegate {
    func authModelDidAuth(authModel: AuthModel) {
        self.dismiss(animated: true, completion: nil)
        authModel.invalidateTimer()
    }
    
    func updateCode(authModel: AuthModel) {
        loadCode()
    }
}

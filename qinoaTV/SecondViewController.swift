//
//  SecondViewController.swift
//  qinoaTV
//
//  Created by Евгений Дац on 18.05.2018.
//  Copyright © 2018 KinoPub. All rights reserved.
//

import UIKit
import LKAlertController
import SwiftyUserDefaults
import AlamofireImage

class SecondViewController: UIViewController {
    fileprivate let accountManager = Container.Manager.account
    private let profileModel = Container.ViewModel.profile()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var changeButton: UIButton!
    
    @IBAction func changeButtonTapped(_ sender: Any) {
        showAccounts()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        accountManager.addDelegate(delegate: self)
        profileModel.loadProfile()
        profileModel.delegate = self
        configProfile()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.items?[2].title = "Account"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.items?[2].title = ""
    }
    
    func configProfile() {
        nameLabel.text = profileModel.user?.username
        profileLabel.text = "Профиль: \(accountManager.accountName)"
        if let image = profileModel.user?.profile.avatar {
            imageView.af_setImage(withURL: URL(string: image + "?s=200&d=https://cdn.service-kp.com/icon/anon_m.png")!,
                                  placeholderImage: UIImage(named: "Circled User Male-100"),
                                  imageTransition: .crossDissolve(0.2))
        }
    }
    
    func showAccounts() {
        let action = ActionSheet(title: "Смена аккаунта", message: "Выберите аккаунт, чтобы назначить его текущим.")
        for account in Defaults[.accountsArray] {
            action.addAction(account, style: .default) { [weak self] (_) in
                self?.accountManager.loginToSelectedAccount(account)
            }
        }
        action.addAction("Добавить аккаунт", style: .default) { [weak self] (_) in
            self?.addAccount()
        }
        action.addAction("Отмена", style: .cancel)
        action.show()
    }
    
    func addAccount() {
        var textField = UITextField()
        textField.placeholder = "Псевдоним"
        Alert(title: "Новый аккаунт", message: "Введите псевдоним для вашего аккаунта.")
        .addTextField(&textField, required: true)
        .addAction("Отмена", style: .cancel)
        .addAction("Создать", style: .default, preferredAction: true) { [weak self] (action) in
            guard let strongSelf = self else { return }
            strongSelf.newAccount(with: textField.text)
        }
        .show(animated: true)
    }
    
    func newAccount(with accountName: String?) {
        guard let accountName = accountName else { return }
        accountManager.loginToNewAccount(accountName)
    }

}

extension SecondViewController: ProfileModelDelegate {
    func didUpdateProfile(model: ProfileModel) {
        configProfile()
    }
}

extension SecondViewController: AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {
        profileModel.loadProfile()
    }
}


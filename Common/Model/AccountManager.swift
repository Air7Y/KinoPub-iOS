//
//  AccountManager.swift
//  KinoPub
//
//  Created by hintoz on 03.03.17.
//  Copyright © 2017 Evgeny Dats. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import KeychainSwift
import Alamofire

protocol AccountManager: class {
    var account: KinopubAccount? { get }
    var hasAccount: Bool { get }
    var requestFactory: RequestFactory { get }
    var accountName: String { get }
    func addDelegate(delegate: AccountManagerDelegate)
    func createAccount(tokenData: TokenResponse)
    func silentlyUpdateAccountWith(accessToken token: String, refreshToken: String)
    func logoutAccount()
    func loginToNewAccount(_ accountName: String)
    func loginToSelectedAccount(_ accountName: String)
}

protocol AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount)
    func accountManagerDidLogout(accountManager: AccountManager)
    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount)
}

extension AccountManagerDelegate {
    func accountManagerDidAuth(accountManager: AccountManager, toAccount account: KinopubAccount) {

    }

    func accountManagerDidLogout(accountManager: AccountManager) {

    }

    func accountManagerDidUpdateToken(accountManager: AccountManager, forAccount account: KinopubAccount) {

    }
}

class AccountManagerImp: AccountManager {
    var delegatesStorage = DelegatesStorage()
    let requestFactory: RequestFactory
    let accountNetworkingService: AccountNetworkingService
    let keychain: KeychainSwift

    var account: KinopubAccount?
    var hasAccount: Bool {
        return account != nil
    }
    var accountName: String
    
    var accessTokenKey: String {
        return AccountKeys.accessToken.rawValue + accountName
    }
    var refreshTokenKey: String {
        return AccountKeys.refreshToken.rawValue + accountName
    }

    init() {
        requestFactory = RequestFactory()
        accountNetworkingService = AccountNetworkingService(requestFactory: requestFactory)
        keychain = KeychainSwift()
        keychain.synchronizable = true
        accountName = Defaults[.currentAccount] ?? "Defaults"
        checkIfAccountExist()
    }

    func addDelegate(delegate: AccountManagerDelegate) {
        delegatesStorage.addDelegate(delegate: delegate as AnyObject)
    }

    func createAccount(tokenData: TokenResponse) {
        keychain.set(tokenData.accessToken!, forKey: accessTokenKey)
        keychain.set(tokenData.refreshToken!, forKey: refreshTokenKey)
        Defaults[.currentAccount] = accountName
        Defaults[.accountsArray].append(accountName)
        self.account = KinopubAccount(accessToken: tokenData.accessToken!, refreshToken: tokenData.refreshToken!)
        self.authAndNotifyDelegates()
    }

    func silentlyUpdateAccountWith(accessToken token: String, refreshToken: String) {
        keychain.set(token, forKey: accessTokenKey)
        keychain.set(refreshToken, forKey: refreshTokenKey)
        self.account = KinopubAccount(accessToken: token, refreshToken: refreshToken)
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidUpdateToken(accountManager: self, forAccount: self.account!)
        }
    }

    func logoutAccount() {
        self.logoutAndNotifyDelegates()
    }
    
    func loginToNewAccount(_ accountName: String) {
        self.accountName = accountName
        resetAccountAndSessionManager()
        notifyDelegates()
    }
    
    func loginToSelectedAccount(_ accountName: String) {
        self.accountName = accountName
        Defaults[.currentAccount] = accountName
        resetAccountAndSessionManager()
        checkIfAccountExist()
    }

    private func checkIfAccountExist() {
        if let accessToken = keychain.get(accessTokenKey) {
            self.account = KinopubAccount(accessToken: accessToken, refreshToken: keychain.get(refreshTokenKey))
            self.authAndNotifyDelegates()
        }
    }

    private func authAndNotifyDelegates() {
        requestFactory.accountManager = self
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidAuth(accountManager: self, toAccount: self.account!)
        }
        self.notifyAboutDeviceIfRequired()
    }

    private func notifyAboutDeviceIfRequired() {
        if account == nil {
            LogManager.shared.log("Account is nil", getVaList([]))
            return
        }
        accountNetworkingService.notifyAboutDevice { error in
            if let error = error {
                LogManager.shared.log("![ERROR] notifyAboutDevice. ", getVaList([error as CVarArg]))
                debugPrint("![ERROR] notifyAboutDevice. \(error.localizedDescription)")
            }
        }
    }

    private func logoutAndNotifyDelegates() {
        accountNetworkingService.unlinkDevice { (error) in
            if let error = error {
                LogManager.shared.log("![ERROR] unlinkDevice. ", getVaList([error as CVarArg]))
                debugPrint("![ERROR] unlinkDevice. \(error.localizedDescription)")
            }
        }
        keychain.clear()
        resetAccountAndSessionManager()
        notifyDelegates()
    }
    
    private func resetAccountAndSessionManager() {
        account = nil
        requestFactory.authorizedSessionManager = nil
    }
    
    private func notifyDelegates() {
        delegatesStorage.enumerateDelegatesWithBlock { [unowned self] (delegate) in
            (delegate as! AccountManagerDelegate).accountManagerDidLogout(accountManager: self)
        }
    }
}

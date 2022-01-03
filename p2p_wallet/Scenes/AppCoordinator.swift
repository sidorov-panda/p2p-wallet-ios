//
//  AppCoordinator.swift
//  p2p_wallet
//
//  Created by Chung Tran on 03/01/2022.
//

import Foundation
import UIKit

class AppCoordinator {
    // MARK: - Properties
    private let window: UIWindow?
    private let storage: AccountStorageType & PincodeStorageType & NameStorageType
    
    // MARK: - Initializer
    init(window: UIWindow?) {
        self.window = window
        self.storage = Resolver.resolve()
    }
    
    // MARK: - Methods
    func start() {
        reload()
    }
    
    func reload() {
        // set placeholder vc
        changeRootViewController(to: PlaceholderViewController())
        
        // try to retrieve account from seed
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let account = self?.storage.account
            DispatchQueue.main.async { [weak self] in
                if account == nil {
//                    self?.showAuthenticationOnMainOnAppear = false
//                    self?.navigationSubject.accept(.createOrRestoreWallet)
                } else if self?.storage.pinCode == nil ||
                            !Defaults.didSetEnableBiometry ||
                            !Defaults.didSetEnableNotifications
                {
//                    self?.showAuthenticationOnMainOnAppear = false
//                    self?.navigationSubject.accept(.onboarding)
                } else {
//                    self?.navigationSubject.accept(.main(showAuthenticationWhenAppears: self?.showAuthenticationOnMainOnAppear ?? false))
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func changeRootViewController(to vc: UIViewController) {
        // TODO: - Animation
        window?.rootViewController = vc
    }
}
